//
// RSDFDatePickerView.m
//
// Copyright (c) 2013 Evadne Wu, http://radi.ws/
// Copyright (c) 2013-2014 Ruslan Skorb, http://lnkd.in/gsBbvb
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "RSDayFlow.h"
#import "RSDFDatePickerCollectionView.h"
#import "RSDFDatePickerCollectionViewLayout.h"
#import "RSDFDatePickerDayCell.h"
#import "RSDFDatePickerMonthHeader.h"
#import "RSDFDatePickerView.h"
#import "RSDFDatePickerDaysOfWeekView.h"
#import "NSCalendar+RSDFAdditions.h"

static NSString * const RSDFDatePickerViewMonthHeaderIdentifier = @"RSDFDatePickerViewMonthHeaderIdentifier";
static NSString * const RSDFDatePickerViewDayCellIdentifier = @"RSDFDatePickerViewDayCellIdentifier";

@interface RSDFDatePickerView () <RSDFDatePickerCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readonly, strong) NSCalendar *calendar;
@property (nonatomic, readonly, assign) RSDFDatePickerDate fromDate;
@property (nonatomic, readonly, assign) RSDFDatePickerDate toDate;
@property (nonatomic, readonly, strong) RSDFDatePickerDaysOfWeekView *daysOfWeekView;
@property (nonatomic, readonly, strong) RSDFDatePickerCollectionView *collectionView;
@property (nonatomic, readonly, strong) RSDFDatePickerCollectionViewLayout *collectionViewLayout;
@property (nonatomic, readonly, strong) NSDate *today;
@property (nonatomic, readonly, assign) NSUInteger daysInWeek;
@property (nonatomic, readonly, strong) NSDate *selectedDate;

@end

@implementation RSDFDatePickerView

@synthesize calendar = _calendar;
@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize daysOfWeekView = _daysOfWeekView;
@synthesize collectionView = _collectionView;
@synthesize collectionViewLayout = _collectionViewLayout;
@synthesize daysInWeek = _daysInWeek;

#pragma mark - Lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:frame];
    if (self) {
        _calendar = calendar;
        [self commonInitializer];
    }
    return self;
}

- (void)layoutSubviews
{
    CGPoint beforeLayoutSubviewsContentOffset = self.collectionView.contentOffset;
    
    [super layoutSubviews];
    
    self.daysOfWeekView.frame = [self daysOfWeekViewFrame];
    if (!self.daysOfWeekView.superview) {
        [self addSubview:self.daysOfWeekView];
    }
    
    self.collectionView.frame = [self collectionViewFrame];
    if (!self.collectionView.superview) {
        [self addSubview:self.collectionView];
        [self scrollToToday:NO];
    } else {
        [self.collectionViewLayout invalidateLayout];
        [self.collectionViewLayout prepareLayout];
        self.collectionView.contentOffset = beforeLayoutSubviewsContentOffset;
    }
}

#pragma mark - Custom Accessors

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _calendar.locale = [NSLocale currentLocale];
    }
    return _calendar;
}

- (CGRect)daysOfWeekViewFrame
{
    BOOL isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    BOOL isPortraitInterfaceOrientation = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    
    CGRect namesOfDaysViewFrame = self.bounds;
    if (isPhone) {
        if (isPortraitInterfaceOrientation) {
            namesOfDaysViewFrame.size.height = 22.0f;
        } else {
            namesOfDaysViewFrame.size.height = 26.0f;
        }
    } else {
        namesOfDaysViewFrame.size.height = 36.0f;
    }
    
    return namesOfDaysViewFrame;
}

- (Class)daysOfWeekViewClass
{
    return [RSDFDatePickerDaysOfWeekView class];
}

- (RSDFDatePickerDaysOfWeekView *)daysOfWeekView
{
    if (!_daysOfWeekView) {
        _daysOfWeekView = [[[self daysOfWeekViewClass] alloc] initWithFrame:[self daysOfWeekViewFrame] calendar:self.calendar];
        [_daysOfWeekView layoutIfNeeded];
    }
    return _daysOfWeekView;
}

- (Class)collectionViewClass
{
    return [RSDFDatePickerCollectionView class];
}

- (CGRect)collectionViewFrame
{
    CGFloat daysOfWeekViewHeight = CGRectGetHeight([self daysOfWeekViewFrame]);
    
    CGRect collectionViewFrame = self.bounds;
    collectionViewFrame.origin.y += daysOfWeekViewHeight;
    collectionViewFrame.size.height -= daysOfWeekViewHeight;
    return collectionViewFrame;
}

- (RSDFDatePickerCollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[[self collectionViewClass] alloc] initWithFrame:[self collectionViewFrame] collectionViewLayout:self.collectionViewLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[self monthHeaderClass] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:RSDFDatePickerViewMonthHeaderIdentifier];
        [_collectionView registerClass:[self dayCellClass] forCellWithReuseIdentifier:RSDFDatePickerViewDayCellIdentifier];
        [_collectionView reloadData];
        [_collectionView layoutIfNeeded];
    }
    return _collectionView;
}

- (Class)collectionViewLayoutClass
{
    return [RSDFDatePickerCollectionViewLayout class];
}

- (RSDFDatePickerCollectionViewLayout *)collectionViewLayout
{
    if (!_collectionViewLayout) {
        NSLocaleLanguageDirection characterDirection = [NSLocale characterDirectionForLanguage:self.calendar.locale.localeIdentifier];
        RSDFDatePickerCollectionViewLayoutDirection layoutDirection;
        if (characterDirection == NSLocaleLanguageDirectionRightToLeft) {
            layoutDirection = RSDFDatePickerCollectionViewLayoutDirectionRightToLeft;
        } else {
            layoutDirection = RSDFDatePickerCollectionViewLayoutDirectionLeftToRight;
        }
        _collectionViewLayout = [[[self collectionViewLayoutClass] alloc] initWithDirection:layoutDirection];
    }
    return _collectionViewLayout;
}

- (Class)monthHeaderClass
{
    return [RSDFDatePickerMonthHeader class];
}

- (Class)dayCellClass
{
    return [RSDFDatePickerDayCell class];
}

- (NSUInteger)daysInWeek
{
    if (_daysInWeek == 0) {
        _daysInWeek = [self.calendar maximumRangeOfUnit:NSCalendarUnitWeekday].length;
    }
    return _daysInWeek;
}

#pragma mark - Handling Notifications

- (void)significantTimeChange:(NSNotification *)notification
{
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [self.collectionView reloadData];
    [self restoreSelection];
}

#pragma mark - Public

- (void)scrollToToday:(BOOL)animated
{
    [self scrollToDate:self.today animated:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    RSDFDatePickerCollectionView *cv = self.collectionView;
    RSDFDatePickerCollectionViewLayout *cvLayout = (RSDFDatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    NSArray *visibleCells = [cv visibleCells];
    if (![visibleCells count])
        return;
    
    NSDateComponents *dateYearMonthComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date];
    NSDate *month = [self.calendar dateFromComponents:dateYearMonthComponents];
    
    _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        return components;
    })()) toDate:month options:0]];
    
    _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = 6;
        return components;
    })()) toDate:month options:0]];
    
    [cv reloadData];
    [cvLayout invalidateLayout];
    [cvLayout prepareLayout];
    
    [self restoreSelection];
    
    NSIndexPath *dateItemIndexPath = [self indexPathForDate:date];
    NSInteger monthSection = [self sectionForDate:date];
    
    CGRect dateItemRect = [self frameForItemAtIndexPath:dateItemIndexPath];
    CGRect monthSectionHeaderRect = [self frameForHeaderForSection:monthSection];
    
    CGFloat delta = CGRectGetMaxY(dateItemRect) - CGRectGetMinY(monthSectionHeaderRect);
    CGFloat actualViewHeight = CGRectGetHeight(cv.frame) - cv.contentInset.top - cv.contentInset.bottom;
    
    if (delta <= actualViewHeight) {
        [self scrollToTopOfSection:monthSection animated:animated];
    } else {
        [cv scrollToItemAtIndexPath:dateItemIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
    }
}

- (void)selectDate:(NSDate *)date
{
    if (![self.selectedDate isEqual:date]) {
        if (self.selectedDate &&
            [self.selectedDate compare:[self dateFromPickerDate:self.fromDate]] != NSOrderedAscending &&
            [self.selectedDate compare:[self dateFromPickerDate:self.toDate]] != NSOrderedDescending) {
            NSIndexPath *previousSelectedCellIndexPath = [self indexPathForDate:self.selectedDate];
            [self.collectionView deselectItemAtIndexPath:previousSelectedCellIndexPath animated:NO];
            UICollectionViewCell *previousSelectedCell = [self.collectionView cellForItemAtIndexPath:previousSelectedCellIndexPath];
            if (previousSelectedCell) {
                [previousSelectedCell setNeedsDisplay];
            }
        }
        
        _selectedDate = date;
        
        if (self.selectedDate &&
            [self.selectedDate compare:[self dateFromPickerDate:self.fromDate]] != NSOrderedAscending &&
            [self.selectedDate compare:[self dateFromPickerDate:self.toDate]] != NSOrderedDescending) {
            NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:self.selectedDate];
            [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPathForSelectedDate];
            if (selectedCell) {
                [selectedCell setNeedsDisplay];
            }
        }
    }
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - Private

- (void)commonInitializer
{
    NSDateComponents *nowYearMonthComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    NSDate *now = [self.calendar dateFromComponents:nowYearMonthComponents];
    
    _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        return components;
    })()) toDate:now options:0]];
    
    _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = 6;
        return components;
    })()) toDate:now options:0]];
    
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(significantTimeChange:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
}

- (void)appendPastDates
{
    [self shiftDatesByComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = -6;
        return dateComponents;
    })())];
}

- (void)appendFutureDates
{
    [self shiftDatesByComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = 6;
        return dateComponents;
    })())];
}

- (void)shiftDatesByComponents:(NSDateComponents *)components
{
    RSDFDatePickerCollectionView *cv = self.collectionView;
    RSDFDatePickerCollectionViewLayout *cvLayout = (RSDFDatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    NSArray *visibleCells = [cv visibleCells];
    if (![visibleCells count])
        return;
    
    NSIndexPath *fromIndexPath = [cv indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];
    NSInteger fromSection = fromIndexPath.section;
    NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
    UICollectionViewLayoutAttributes *fromAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
    CGPoint fromSectionOrigin = [self convertPoint:fromAttrs.frame.origin fromView:cv];
    
    _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromPickerDate:self.fromDate] options:0]];
    _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromPickerDate:self.toDate] options:0]];
    
#if 0
    
    //	This solution trips up the collection view a bit
    //	because our reload is reactionary, and happens before a relayout
    //	since we must do it to avoid flickering and to heckle the CA transaction (?)
    //	that could be a small red flag too
    
    [cv performBatchUpdates:^{
        
        if (components.month < 0) {
            
            [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                cv.numberOfSections - abs(components.month),
                abs(components.month)
            }]];
            
            [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                0,
                abs(components.month)
            }]];
            
        } else {
            
            [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                cv.numberOfSections,
                abs(components.month)
            }]];
            
            [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                0,
                abs(components.month)
            }]];
            
        }
        
    } completion:^(BOOL finished) {
        
        NSLog(@"%s %x", __PRETTY_FUNCTION__, finished);
        
    }];
    
    for (UIView *view in cv.subviews)
        [view.layer removeAllAnimations];
    
#else
    
    [cv reloadData];
    [cvLayout invalidateLayout];
    [cvLayout prepareLayout];
    
    [self restoreSelection];
    
#endif
    
    NSInteger toSection = [self sectionForDate:fromSectionOfDate];
    UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
    CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:cv];
    
    [cv setContentOffset:(CGPoint) {
        cv.contentOffset.x,
        cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
    }];
}

- (NSInteger)sectionForDate:(NSDate *)date;
{
    return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateForFirstDayInSection:0] toDate:date options:0].month;
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section
{
    return [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = section;
        return dateComponents;
    })()) toDate:[self dateFromPickerDate:self.fromDate] options:0];
}

- (NSUInteger)numberOfWeeksForMonthOfDate:(NSDate *)date
{
#if 0
    
    NSRange weekRange = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    // Unknown Apple's bug with `NSRange.length` in NSIslamicCalendar
    // Tested on iOS 7.0 (Simulator) / iOS 7.1.2 (Device) / iOS 8.0 (Simulator)
    // Xcode Version 5.1.1 (5B1008), XCode Version 6.0 (6A267n)
    // Monday, Shawwal 29, 1435 AH, 11:59:40 PM
    
    // Example: Friday, Muharram 29, 1436 AH at 12:00:00 AM GMT+03:00
    NSUInteger incorrectNSRangeLength1 = NSUIntegerMax - 44; // must be 5
    
    // Example: Wednesday, Muharram 29, 1434 AH at 12:00:00 AM GMT+03:00
    NSUInteger incorrectNSRangeLength2 = NSUIntegerMax - 45; // must be 5
    
    if ((weekRange.length == incorrectNSRangeLength1) || (weekRange.length == incorrectNSRangeLength2)) {
        NSLog(@"%lu", (unsigned long)(weekRange.length));
        return 5;
    } else {
        return weekRange.length;
    }
    
#else
    
    NSDate *firstDayInMonth = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date]];
    
    NSDate *lastDayInMonth = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = 1;
        dateComponents.day = -1;
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    
    NSDate *fromFirstWeekday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:firstDayInMonth];
        dateComponents.weekday = self.calendar.firstWeekday;
        return dateComponents;
    })())];
    
    NSDate *toFirstWeekday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:lastDayInMonth];
        dateComponents.weekday = self.calendar.firstWeekday;
        return dateComponents;
    })())];
    
    return 1 + [self.calendar components:NSCalendarUnitWeekOfYear fromDate:fromFirstWeekday toDate:toFirstWeekday options:0].weekOfYear;
    
#endif
}

- (NSDate *)dateFromPickerDate:(RSDFDatePickerDate)dateStruct
{
    return [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:dateStruct]];
}

- (NSDateComponents *)dateComponentsFromPickerDate:(RSDFDatePickerDate)dateStruct
{
    NSDateComponents *components = [NSDateComponents new];
    components.year = dateStruct.year;
    components.month = dateStruct.month;
    components.day = dateStruct.day;
    return components;
}

- (RSDFDatePickerDate)pickerDateFromDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return (RSDFDatePickerDate) {
        components.year,
        components.month,
        components.day
    };
}

- (NSUInteger)reorderedWeekday:(NSUInteger)weekday
{
    NSInteger ordered = weekday - self.calendar.firstWeekday;
    if (ordered < 0) {
        ordered = self.daysInWeek + ordered;
    }
    
    return ordered;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    NSInteger monthSection = [self sectionForDate:date];
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:monthSection];
    NSUInteger weekday = [self reorderedWeekday:[self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday];
    NSInteger dateItem = [self.calendar components:NSCalendarUnitDay fromDate:firstDayInMonth toDate:date options:0].day + weekday;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:dateItem inSection:monthSection];
    
    return indexPath;
}

- (CGRect)frameForHeaderForSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    
    return attributes.frame;
}

- (void)scrollToTopOfSection:(NSInteger)section animated:(BOOL)animated
{
	CGRect headerRect = [self frameForHeaderForSection:section];
	CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - _collectionView.contentInset.top);
	[_collectionView setContentOffset:topOfHeader animated:animated];
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    return attributes.frame;
}

- (void)restoreSelection
{
    if (self.selectedDate &&
        [self.selectedDate compare:[self dateFromPickerDate:self.fromDate]] != NSOrderedAscending &&
        [self.selectedDate compare:[self dateFromPickerDate:self.toDate]] != NSOrderedDescending) {
        NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:self.selectedDate];
        [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPathForSelectedDate];
        if (selectedCell) {
            [selectedCell setNeedsDisplay];
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateFromPickerDate:self.fromDate] toDate:[self dateFromPickerDate:self.toDate] options:0].month;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.daysInWeek * [self numberOfWeeksForMonthOfDate:[self dateForFirstDayInSection:section]];
}

- (RSDFDatePickerDayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RSDFDatePickerDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RSDFDatePickerViewDayCellIdentifier forIndexPath:indexPath];
    
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:indexPath.section];
    RSDFDatePickerDate firstDayPickerDate = [self pickerDateFromDate:firstDayInMonth];
    NSUInteger weekday = [self reorderedWeekday:[self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday];
    
    NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = indexPath.item - weekday;
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    RSDFDatePickerDate cellPickerDate = [self pickerDateFromDate:cellDate];
    
    cell.date = cellPickerDate;
    cell.dateLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(cellPickerDate.day)];
    
    cell.notThisMonth = !((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
    if (!cell.isNotThisMonth) {
        weekday = [self.calendar components:NSCalendarUnitWeekday fromDate:cellDate].weekday;
        cell.dayOff = (weekday == 1) || (weekday == 7);
        
        if ([self.dataSource respondsToSelector:@selector(datePickerView:shouldMarkDate:)]) {
            cell.marked = [self.dataSource datePickerView:self shouldMarkDate:cellDate];
            
            if (cell.marked && [self.dataSource respondsToSelector:@selector(datePickerView:isCompletedAllTasksOnDate:)]) {
                cell.completed = [self.dataSource datePickerView:self isCompletedAllTasksOnDate:cellDate];
            }
        }
        
        cell.today = ([cellDate compare:_today] == NSOrderedSame) ? YES : NO;
    }
    
    [cell setNeedsDisplay];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        RSDFDatePickerMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:RSDFDatePickerViewMonthHeaderIdentifier forIndexPath:indexPath];
        
        NSString *dateFormatterName = [NSString stringWithFormat:@"calendarMonthHeader_%@_%@", [self.calendar calendarIdentifier], [[self.calendar locale] localeIdentifier]];
        NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:dateFormatterName withConstructor:^{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setCalendar:self.calendar];
            [dateFormatter setLocale:[self.calendar locale]];
            return dateFormatter;
        }];
        
        NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
        RSDFDatePickerDate date = [self pickerDateFromDate:formattedDate];
        
        monthHeader.date = date;
        
        NSString *monthString = [dateFormatter shortStandaloneMonthSymbols][date.month - 1];
        monthHeader.dateLabel.text = [[NSString stringWithFormat:@"%@ %lu", monthString, (unsigned long)(date.year)] uppercaseString];
        
        RSDFDatePickerDate today = [self pickerDateFromDate:_today];
        if ( (today.month == date.month) && (today.year == date.year) ) {
            monthHeader.currentMonth = YES;
        } else {
            monthHeader.currentMonth = NO;
        }
        
        return monthHeader;
        
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate

//	We are cheating by piggybacking on view state to avoid recalculation
//	in -collectionView:shouldHighlightItemAtIndexPath:
//	and -collectionView:shouldSelectItemAtIndexPath:.

//	A native refactoring process might introduce duplicate state which is bad too.

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).isNotThisMonth) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(datePickerView:shouldHighlightDate:)]) {
        RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]);
        NSDate *date = cell ? [self dateFromPickerDate:cell.date] : nil;
        return [self.delegate datePickerView:self shouldHighlightDate:date];
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setNeedsDisplay];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell setNeedsDisplay];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).isNotThisMonth) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(datePickerView:shouldSelectDate:)]) {
        RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]);
        NSDate *date = cell ? [self dateFromPickerDate:cell.date] : nil;
        return [self.delegate datePickerView:self shouldSelectDate:date];
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]);
    NSDate *date = cell ? [self dateFromPickerDate:cell.date] : nil;
    
    [self selectDate:date];
    
    if ([self.delegate respondsToSelector:@selector(datePickerView:didSelectDate:)]) {
        [self.delegate datePickerView:self didSelectDate:date];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RSDFDatePickerCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return [collectionViewLayout selfHeaderReferenceSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RSDFDatePickerCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionViewLayout selfItemSize];
}

#pragma mark - RSDFDatePickerCollectionViewDelegate

- (void)pickerCollectionViewWillLayoutSubviews:(RSDFDatePickerCollectionView *)pickerCollectionView
{
    //	Note: relayout is slower than calculating 3 or 6 months’ worth of data at a time
    //	So we punt 6 months at a time.
    
    //	Running Time	Self		Symbol Name
    //
    //	1647.0ms   23.7%	1647.0	 	objc_msgSend
    //	193.0ms    2.7%	193.0	 	-[NSIndexPath compare:]
    //	163.0ms    2.3%	163.0	 	objc::DenseMap<objc_object*, unsigned long, true, objc::DenseMapInfo<objc_object*>, objc::DenseMapInfo<unsigned long> >::LookupBucketFor(objc_object* const&, std::pair<objc_object*, unsigned long>*&) const
    //	141.0ms    2.0%	141.0	 	DYLD-STUB$$-[_UIHostedTextServiceSession dismissTextServiceAnimated:]
    //	138.0ms    1.9%	138.0	 	-[NSObject retain]
    //	136.0ms    1.9%	136.0	 	-[NSIndexPath indexAtPosition:]
    //	124.0ms    1.7%	124.0	 	-[_UICollectionViewItemKey isEqual:]
    //	118.0ms    1.7%	118.0	 	_objc_rootReleaseWasZero
    //	105.0ms    1.5%	105.0	 	DYLD-STUB$$CFDictionarySetValue$shim
    
    if (pickerCollectionView.contentOffset.y < 0.0f) {
        [self appendPastDates];
    }
    
    if (pickerCollectionView.contentOffset.y > (pickerCollectionView.contentSize.height - CGRectGetHeight(pickerCollectionView.bounds))) {
        [self appendFutureDates];
    }
}

@end

//
// RSDFDatePickerView.m
//
// Copyright (c) 2013 Evadne Wu, http://radi.ws/
// Copyright (c) 2013-2015 Ruslan Skorb, http://ruslanskorb.com
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
#import "RSDFDatePickerCollectionView.h"
#import "RSDFDatePickerCollectionViewLayout.h"
#import "RSDFDatePickerDate.h"
#import "RSDFDatePickerDayCell.h"
#import "RSDFDatePickerMonthHeader.h"
#import "RSDFDatePickerView.h"
#import "RSDFDatePickerDaysOfWeekView.h"
#import "NSCalendar+RSDFAdditions.h"

static NSString * const RSDFDatePickerViewMonthHeaderIdentifier = @"RSDFDatePickerViewMonthHeaderIdentifier";
static NSString * const RSDFDatePickerViewDayCellIdentifier = @"RSDFDatePickerViewDayCellIdentifier";

@interface RSDFDatePickerView () <RSDFDatePickerCollectionViewDelegate, RSDFDatePickerDayCellDelegate>

@property (nonatomic, readonly, strong) NSCalendar *calendar;
@property (nonatomic, readonly, strong) RSDFDatePickerDaysOfWeekView *daysOfWeekView;
@property (nonatomic, readonly, strong) RSDFDatePickerCollectionView *collectionView;
@property (nonatomic, readonly, strong) RSDFDatePickerCollectionViewLayout *collectionViewLayout;
@property (nonatomic, readonly, strong) NSDate *today;
@property (nonatomic, readonly, assign) NSUInteger daysInWeek;
@property (nonatomic, readonly, strong) NSDate *selectedDate;
@property (nonatomic, readonly, strong) NSDate *selectedStartDateRange;
@property (nonatomic, readonly, strong) NSDate *selectedEndDateRange;
@property (nonatomic, readonly, strong) NSMutableArray<NSDate *> *selectedDates;

// From and to date are the currently displayed dates in the calendar
// These values change in infinite scrolling mode
@property (nonatomic, readonly, assign) RSDFDatePickerDate fromDate;
@property (nonatomic, readonly, assign) RSDFDatePickerDate toDate;

// start and end date are date limits displayed in the calendar (No infinite scrolling)
@property (nonatomic, readonly, strong) NSDate *startDate;
@property (nonatomic, readonly, strong) NSDate *endDate;

@end

@implementation RSDFDatePickerView

@synthesize calendar = _calendar;
@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize daysOfWeekView = _daysOfWeekView;
@synthesize collectionView = _collectionView;
@synthesize collectionViewLayout = _collectionViewLayout;
@synthesize daysInWeek = _daysInWeek;
@synthesize selectionMode = _selectionMode;

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

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    self = [super initWithFrame:frame];
    if (self) {
        _startDate = startDate ? [self dateWithoutTimeComponents:startDate] : nil;
        _endDate = endDate ? [self dateWithoutTimeComponents:endDate] : nil;
        _calendar = calendar;
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar
{
    self = [self initWithFrame:frame calendar:calendar startDate:nil endDate:nil];
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

- (void)setSelectionMode:(RSDFSelectionMode)selectionMode
{
    _selectionMode = selectionMode;
    
    self.collectionView.allowsMultipleSelection = selectionMode != RSDFSelectionModeSingle;
}

#pragma mark - Handling Notifications

- (void)significantTimeChange:(NSNotification *)notification
{
    [self updateCalendarTodayDate];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self updateCalendarTodayDate];
}

#pragma mark - Public

- (void)scrollToToday:(BOOL)animated
{
    [self scrollToDate:self.today animated:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    if (self.startDate && [date compare:self.startDate] == NSOrderedAscending) {
        return;
    }
    
    if (self.endDate && [date compare:self.endDate] == NSOrderedDescending) {
        return;
    }
    
    RSDFDatePickerCollectionView *cv = self.collectionView;
    RSDFDatePickerCollectionViewLayout *cvLayout = (RSDFDatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    NSDateComponents *dateYearMonthComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date];
    NSDate *month = [self.calendar dateFromComponents:dateYearMonthComponents];
	
    // If startDate exists don't try to update toDate because it was done on init, and date limit should remain
    if (!self.startDate) {
        _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
            NSDateComponents *components = [NSDateComponents new];
            components.month = -6;
            return components;
        })()) toDate:month options:0]];
    }
    
    // If endDate exists don't try to update toDate because it was done on init, and date limit should remain
    if (!self.endDate) {
        _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
            NSDateComponents *components = [NSDateComponents new];
            components.month = 6;
            return components;
        })()) toDate:month options:0]];
    }
	
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
    if (self.selectionMode == RSDFSelectionModeSingle) {
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
    else if (self.selectionMode == RSDFSelectionModeMultiple) {
        if ([date compare:[self dateFromPickerDate:self.fromDate]] != NSOrderedAscending &&
            [date compare:[self dateFromPickerDate:self.toDate]] != NSOrderedDescending) {
         
            if ([self.selectedDates containsObject:date]) {
                [self.selectedDates removeObject:date];
                NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:date];
                [self.collectionView deselectItemAtIndexPath:indexPathForSelectedDate animated:NO];
            }
            else {
                [self.selectedDates addObject:date];
                NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:date];
                [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    }
}

- (void)selectDateRange:(NSDate *)firstDate lastDate:(NSDate *)lastDate
{
    if (!firstDate || !lastDate) {
        return;
    }
    
    [self selectDateInDateRange:firstDate];
    [self selectDateInDateRange:lastDate];
}

- (void)deselectDatesAnimated:(BOOL)animated {
    _selectedDate = nil;
    _selectedStartDateRange = nil;
    _selectedEndDateRange = nil;

    for (NSIndexPath *indexPath in _collectionView.indexPathsForSelectedItems) {
        [_collectionView deselectItemAtIndexPath:indexPath animated:animated];
    }
}

- (void)reloadData
{
    [self.collectionView reloadData];
    [self restoreSelection];
}

#pragma mark - Private

- (void)updateCalendarTodayDate {
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [self.collectionView reloadData];
    [self restoreSelection];
}

- (void)handleSelectAndDeselect:(NSIndexPath *)indexPath
{
    RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[self.collectionView cellForItemAtIndexPath:indexPath]);
    NSDate *date = cell ? [self dateFromPickerDate:cell.date] : nil;
    
    switch (self.selectionMode) {
        case RSDFSelectionModeSingle: {
            [self selectDate:date];
            
            if ([self.delegate respondsToSelector:@selector(datePickerView:didSelectDate:)]) {
                [self.delegate datePickerView:self didSelectDate:date];
            }
            
            break;
        }
            
        case RSDFSelectionModeMultiple: {
            [self selectDate:date];
            
            if ([self.delegate respondsToSelector:@selector(datePickerView:didSelectDates:)]) {
                [self.delegate datePickerView:self didSelectDates:self.selectedDates.copy];
            }
            
            break;
        }
            
        case RSDFSelectionModeRange: {
            [self selectDateInDateRange:date];
            
            if ([self.delegate respondsToSelector:@selector(datePickerView:didSelectStartDate:endDate:)]) {
                [self.delegate datePickerView:self didSelectStartDate:self.selectedStartDateRange endDate:self.selectedEndDateRange];
            }
            
            break;
        }
    }
}

- (void)selectDateInDateRange:(NSDate *)date
{
    __weak typeof(self) weakSelf = self;
    
    // Range already completed, user is trying to cancel and start a new range (reset)
    if (self.selectedStartDateRange && self.selectedEndDateRange) {
        
        NSIndexPath *firstIndexPath = [self indexPathForDate:self.selectedStartDateRange];
        NSIndexPath *lastIndexPath = [self indexPathForDate:self.selectedEndDateRange];
        
        [self enumerateBetweenFirstIndexPath:firstIndexPath secondIndexPath:lastIndexPath withBlock:^(NSIndexPath *indexPath) {
            [weakSelf.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            [[weakSelf.collectionView cellForItemAtIndexPath:indexPath] setNeedsDisplay];
        }];
        
        _selectedStartDateRange = nil;
        _selectedEndDateRange = nil;
    }
    
    if (self.selectedStartDateRange == nil) {
        _selectedStartDateRange = date;
        
        NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:date];
        [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    else {
        // Rearrange first an second date so that they are in ascending order
        if ([date compare:self.selectedStartDateRange] == NSOrderedAscending) {
            _selectedEndDateRange = self.selectedStartDateRange;
            _selectedStartDateRange = date;
        }
        else {
            _selectedEndDateRange = date;
        }
        
        NSIndexPath *firstIndexPath = [self indexPathForDate:self.selectedStartDateRange];
        NSIndexPath *lastIndexPath = [self indexPathForDate:self.selectedEndDateRange];
        
        [self enumerateBetweenFirstIndexPath:firstIndexPath secondIndexPath:lastIndexPath withBlock:^(NSIndexPath *indexPath) {
            [weakSelf.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            [[weakSelf.collectionView cellForItemAtIndexPath:indexPath] setNeedsDisplay];
        }];
    }
}

- (void)enumerateBetweenFirstIndexPath:(NSIndexPath *)firstIndexPath secondIndexPath:(NSIndexPath *)lastIndexPath withBlock:(void (^)(NSIndexPath *))block
{
    for (NSUInteger section = firstIndexPath.section ; section <= lastIndexPath.section ; section++) {
        
        NSUInteger rowToStart = section == firstIndexPath.section ? firstIndexPath.row : 0;
        NSUInteger rowToEnd = section == lastIndexPath.section ? lastIndexPath.row : [self collectionView:self.collectionView numberOfItemsInSection:section];
        
        for (NSUInteger row = rowToStart ; row <= rowToEnd ; row++) {

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            block(indexPath);
        }
    }
}

- (NSDate *)dateWithoutTimeComponents:(NSDate *)date
{
    NSDateComponents *dateComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    return [self.calendar dateFromComponents:dateComponents];
}

- (NSDate *)dateWithFirstDayOfMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    dateComponents.day = 1;
    return [self.calendar dateFromComponents:dateComponents];
}

- (NSDate *)dateByMovingToEndOfMonth:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    components.month = components.month + 1;
    return [self.calendar dateFromComponents:components];
}

- (void)commonInitializer
{
    _selectedDates = [NSMutableArray array];
    self.selectionMode = RSDFSelectionModeSingle;
    
    NSDateComponents *nowYearMonthComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    NSDate *now = [self.calendar dateFromComponents:nowYearMonthComponents];
	
    if (self.startDate) {
        _fromDate = [self pickerDateFromDate:[self dateWithFirstDayOfMonth:self.startDate]];
    } else {
        _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
            NSDateComponents *components = [NSDateComponents new];
            components.month = -6;
            return components;
        })()) toDate:now options:0]];
    }
    
    if (self.endDate) {
        _toDate = [self pickerDateFromDate:[self dateByMovingToEndOfMonth:self.endDate]];
    } else {
        _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
            NSDateComponents *components = [NSDateComponents new];
            components.month = 6;
            return components;
        })()) toDate:now options:0]];
    }
	
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(significantTimeChange:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
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
	
    if (!self.startDate) {
        _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromPickerDate:self.fromDate] options:0]];
    }
	
    if (!self.endDate) {
        _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromPickerDate:self.toDate] options:0]];
    }
    
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
    switch (self.selectionMode) {
        case RSDFSelectionModeSingle: {
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
            
            break;
        }
    
        case RSDFSelectionModeMultiple: {
            for (NSDate *date in self.selectedDates) {
                if ([date compare:[self dateFromPickerDate:self.fromDate]] != NSOrderedAscending &&
                    [date compare:[self dateFromPickerDate:self.toDate]] != NSOrderedDescending) {
                    
                    NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:date];
                    [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                    UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPathForSelectedDate];
                    
                    if (selectedCell) {
                        [selectedCell setNeedsDisplay];
                    }
                }
            }
            break;
        }
    
        case RSDFSelectionModeRange: {
            // If both exist select all items in range
            if (self.selectedStartDateRange && self.selectedEndDateRange) {
                NSIndexPath *firstIndexPath = [self indexPathForDate:self.selectedStartDateRange];
                NSIndexPath *lastIndexPath = [self indexPathForDate:self.selectedEndDateRange];
                
                if (firstIndexPath && lastIndexPath) {
                    __weak typeof(self) weakSelf = self;
                    
                    [self enumerateBetweenFirstIndexPath:firstIndexPath secondIndexPath:lastIndexPath withBlock:^(NSIndexPath *indexPath) {
                        [weakSelf.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                        [[weakSelf.collectionView cellForItemAtIndexPath:indexPath] setNeedsDisplay];
                    }];
                }
            }
            // If only one exists only select that one
            else {
                if (self.selectedStartDateRange || self.selectedEndDateRange) {
                    NSIndexPath *indexPath =  [self indexPathForDate:self.selectedStartDateRange ? self.selectedStartDateRange : self.selectedEndDateRange];
                    
                    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    [[self.collectionView cellForItemAtIndexPath:indexPath] setNeedsDisplay];
                }
                
                break;
            }
        }
    }
}

#pragma mark - RSDFDatePickerDayCellDelegate

- (void)datePickerDayCellDidUpdateUserInterface:(RSDFDatePickerDayCell *)cell {
    if ([self.delegate respondsToSelector:@selector(datePickerView:didDisplayCell:)]) {
        [self.delegate datePickerView:self didDisplayCell:(RSDFDatePickerDayCell *)cell];
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
    cell.delegate = self;
    
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
            
            if (cell.marked) {
                if ([self.dataSource respondsToSelector:@selector(datePickerView:markImageForDate:)]) {
                    cell.markImage = [self.dataSource datePickerView:self markImageForDate:cellDate];
                } else if ([self.dataSource respondsToSelector:@selector(datePickerView:markImageColorForDate:)]) {
                    cell.markImageColor = [self.dataSource datePickerView:self markImageColorForDate:cellDate];
                }
            }
        }
        
        NSComparisonResult result = [_today compare:cellDate];
        cell.today = (result == NSOrderedSame);
        cell.pastDate = (result == NSOrderedDescending);
		
        if ((self.startDate && [cellDate compare:self.startDate] == NSOrderedAscending) ||
            (self.endDate && [cellDate compare:self.endDate] == NSOrderedDescending)) {
            cell.outOfRange = YES;
        } else {
            cell.outOfRange = NO;
        }
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
    RSDFDatePickerDayCell *cell = (RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.isNotThisMonth || cell.isOutOfRange) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(datePickerView:shouldHighlightDate:)]) {
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
    RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[self.collectionView cellForItemAtIndexPath:indexPath]);
    
    if (cell.isNotThisMonth || cell.isOutOfRange) {
        return NO;
    }
	
    if ([self.delegate respondsToSelector:@selector(datePickerView:shouldSelectDate:)]) {
        NSDate *date = cell ? [self dateFromPickerDate:cell.date] : nil;
        return [self.delegate datePickerView:self shouldSelectDate:date];
    }
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleSelectAndDeselect:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectionMode == RSDFSelectionModeRange) {
        [self handleSelectAndDeselect:indexPath];
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
    
    if (!self.startDate && pickerCollectionView.contentOffset.y < 0.0f) {
        [self appendPastDates];
    }
    
    if (!self.endDate && pickerCollectionView.contentOffset.y > (pickerCollectionView.contentSize.height - CGRectGetHeight(pickerCollectionView.bounds))) {
        [self appendFutureDates];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isPagingEnabled) {
            if (!self.startDate && scrollView.contentOffset.y < CGRectGetHeight(scrollView.bounds) * 2) {
                [self appendPastDates];
            }
            
            if (!self.endDate && scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) * 2 > scrollView.contentSize.height) {
                [self appendFutureDates];
            }
        }
    });
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.isPagingEnabled) {
        NSArray *sortedIndexPathsForVisibleItems = [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath * obj2) {
            return obj1.section > obj2.section;
        }];
        
        NSUInteger visibleSection;
        NSUInteger nextSection;
        if (velocity.y > 0.0) {
            visibleSection = [[sortedIndexPathsForVisibleItems firstObject] section];
            
            if (self.endDate && visibleSection >= [self sectionForDate:self.endDate]) {
                nextSection = visibleSection;
            } else {
                nextSection = visibleSection + 1;
            }
        } else if (velocity.y < 0.0) {
            visibleSection = [[sortedIndexPathsForVisibleItems lastObject] section];
            
            if (self.startDate && visibleSection <= [self sectionForDate:self.startDate]) {
                nextSection = visibleSection;
            } else {
                nextSection = visibleSection - 1;
            }
        } else {
            visibleSection = [sortedIndexPathsForVisibleItems[sortedIndexPathsForVisibleItems.count / 2] section];
            nextSection = visibleSection;
        }
        
        CGRect headerRect = [self frameForHeaderForSection:nextSection];
        CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - self.collectionView.contentInset.top);
        CGFloat maxYContentOffset = self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.bounds);
        if (topOfHeader.y > maxYContentOffset) {
            topOfHeader.y = maxYContentOffset;
        }
        
        *targetContentOffset = topOfHeader;
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

@end

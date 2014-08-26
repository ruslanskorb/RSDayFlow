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

static const CGFloat RSDFDatePickerViewDaysOfWeekViewWidth = 320.0f;
static const CGFloat RSDFDatePickerViewDaysOfWeekViewHeight = 22.0f;

@interface RSDFDatePickerView () <RSDFDatePickerCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, readonly, strong) NSCalendar *calendar;
@property (nonatomic, readonly, assign) RSDFDatePickerDate fromDate;
@property (nonatomic, readonly, assign) RSDFDatePickerDate toDate;
@property (nonatomic, readonly, strong) RSDFDatePickerDaysOfWeekView *daysOfWeekView;
@property (nonatomic, readonly, strong) RSDFDatePickerCollectionView *collectionView;
@property (nonatomic, readonly, strong) RSDFDatePickerCollectionViewLayout *collectionViewLayout;
@property (nonatomic, readonly, strong) NSDate *today;
@property (nonatomic, readonly, assign) NSUInteger daysInWeek;

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
    [super layoutSubviews];
	
    self.daysOfWeekView.frame = [self daysOfWeekViewFrame];
    if (!self.daysOfWeekView.superview) {
        [self addSubview:self.daysOfWeekView];
    }
    
    self.collectionView.frame = [self collectionViewFrame];
	if (!self.collectionView.superview) {
        [self scrollToToday:NO];
		[self addSubview:self.collectionView];
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	if (newSuperview && !_collectionView) {
		//	do some initialization!
        RSDFDatePickerDaysOfWeekView *v = self.daysOfWeekView;
        [v layoutIfNeeded];
        
		UICollectionView *cv = self.collectionView;
        [cv layoutIfNeeded];
	}
}

#pragma mark - Custom Accessors

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _calendar.locale = [NSLocale currentLocale];
    }
    return _calendar;
}

- (CGRect)daysOfWeekViewFrame
{
    CGRect namesOfDaysViewFrame = self.bounds;
    namesOfDaysViewFrame.origin.x = (CGRectGetWidth(self.bounds) - RSDFDatePickerViewDaysOfWeekViewWidth) / 2;
    namesOfDaysViewFrame.size.width = RSDFDatePickerViewDaysOfWeekViewWidth;
    namesOfDaysViewFrame.size.height = RSDFDatePickerViewDaysOfWeekViewHeight;
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
    }
    return _daysOfWeekView;
}

- (Class)collectionViewClass
{
    return [RSDFDatePickerCollectionView class];
}

- (CGRect)collectionViewFrame
{
    CGRect collectionViewFrame = self.bounds;
    collectionViewFrame.origin.x = (CGRectGetWidth(self.bounds) - RSDFDatePickerViewDaysOfWeekViewWidth) / 2;
    collectionViewFrame.origin.y += RSDFDatePickerViewDaysOfWeekViewHeight;
    collectionViewFrame.size.width = RSDFDatePickerViewDaysOfWeekViewWidth;
    collectionViewFrame.size.height -= RSDFDatePickerViewDaysOfWeekViewHeight;
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
        _collectionViewLayout = [[[self collectionViewLayoutClass] alloc] init];
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
        _daysInWeek = [self.calendar maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
    }
    return _daysInWeek;
}

#pragma mark - Handling Notifications

- (void)significantTimeChange:(NSNotification *)notification
{
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [self.collectionView reloadData];
}

#pragma mark - Public

- (void)scrollToToday:(BOOL)animated
{
    RSDFDatePickerCollectionView *cv = self.collectionView;
	RSDFDatePickerCollectionViewLayout *cvLayout = (RSDFDatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
	
	NSArray *visibleCells = [self.collectionView visibleCells];
	if (![visibleCells count])
		return;
    
    NSDateComponents *nowYearMonthComponents = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
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
    
    [cv reloadData];
	[cvLayout invalidateLayout];
	[cvLayout prepareLayout];
    
    NSInteger section = [self sectionForDate:_today];
    
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:section];
    NSUInteger weekday = [self.calendar components:NSWeekdayCalendarUnit fromDate:firstDayInMonth].weekday;
    NSInteger item = [self.calendar components:NSDayCalendarUnit fromDate:firstDayInMonth toDate:self.today options:0].day + (weekday - self.calendar.firstWeekday);
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [self.collectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - Private

- (void)commonInitializer
{
    NSDateComponents *nowYearMonthComponents = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
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
    
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
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
	
	NSArray *visibleCells = [self.collectionView visibleCells];
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
    return [self.calendar components:NSMonthCalendarUnit fromDate:[self dateForFirstDayInSection:0] toDate:date options:0].month;
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
    
	NSDate *firstDayInMonth = [self.calendar dateFromComponents:[self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date]];
	
	NSDate *lastDayInMonth = [self.calendar dateByAddingComponents:((^{
		NSDateComponents *dateComponents = [NSDateComponents new];
		dateComponents.month = 1;
		dateComponents.day = -1;
		return dateComponents;
	})()) toDate:firstDayInMonth options:0];
    
	NSDate *fromSunday = [self.calendar dateFromComponents:((^{
		NSDateComponents *dateComponents = [self.calendar components:NSWeekOfYearCalendarUnit|NSYearForWeekOfYearCalendarUnit fromDate:firstDayInMonth];
		dateComponents.weekday = 1;
		return dateComponents;
	})())];
	
	NSDate *toSunday = [self.calendar dateFromComponents:((^{
		NSDateComponents *dateComponents = [self.calendar components:NSWeekOfYearCalendarUnit|NSYearForWeekOfYearCalendarUnit fromDate:lastDayInMonth];
		dateComponents.weekday = 1;
		return dateComponents;
	})())];
	
	return 1 + [self.calendar components:NSWeekOfYearCalendarUnit fromDate:fromSunday toDate:toSunday options:0].weekOfYear;
    
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
	NSDateComponents *components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
	return (RSDFDatePickerDate) {
		components.year,
		components.month,
		components.day
	};
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.calendar components:NSMonthCalendarUnit fromDate:[self dateFromPickerDate:self.fromDate] toDate:[self dateFromPickerDate:self.toDate] options:0].month;
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
	NSUInteger weekday = [self.calendar components:NSWeekdayCalendarUnit fromDate:firstDayInMonth].weekday;
	
	NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
		NSDateComponents *dateComponents = [NSDateComponents new];
		dateComponents.day = indexPath.item - (weekday - self.calendar.firstWeekday);
		return dateComponents;
	})()) toDate:firstDayInMonth options:0];
	RSDFDatePickerDate cellPickerDate = [self pickerDateFromDate:cellDate];
	
	cell.date = cellPickerDate;
    cell.dateLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(cellPickerDate.day)];
    
	cell.notThisMonth = !((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
    if (!cell.isNotThisMonth) {
        weekday = [self.calendar components:NSWeekdayCalendarUnit fromDate:cellDate].weekday;
        cell.dayOff = (weekday == 1) || (weekday == 7);
        
        if ([self.dataSource respondsToSelector:@selector(datePickerViewMarkedDates:)]) {
            NSDictionary *markedDates = [self.dataSource datePickerViewMarkedDates:self];
            NSNumber *markedDateState = [markedDates objectForKey:cellDate];
            if (markedDateState) {
                cell.marked = YES;
                cell.completed = [markedDateState boolValue];
            } else {
                cell.marked = NO;
                cell.completed = NO;
            }
        }
        
        cell.today = ([cellDate compare:_today] == NSOrderedSame) ? YES : NO;
    }
    
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
	return !((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).isNotThisMonth;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return !((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).isNotThisMonth;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(datePickerView:didSelectDate:)]) {
        RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]);
        NSDate *selectedDate = cell ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]] : nil;
        [self.delegate datePickerView:self didSelectDate:selectedDate];
    }
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

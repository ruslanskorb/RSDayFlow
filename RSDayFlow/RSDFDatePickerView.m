#import <QuartzCore/QuartzCore.h>
#import "RSDayFlow.h"
#import "RSDFDatePickerCollectionView.h"
#import "RSDFDatePickerDayCell.h"
#import "RSDFDatePickerMonthHeader.h"
#import "RSDFDatePickerView.h"
#import "NSCalendar+RSDFAdditions.h"

static NSString * const DFDatePickerViewCellIdentifier = @"dateCell";
static NSString * const DFDatePickerViewMonthHeaderIdentifier = @"monthHeader";

@interface RSDFDatePickerView () <RSDFDatePickerCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, readonly, strong) NSCalendar *calendar;
@property (nonatomic, readonly, assign) RSDFDatePickerDate fromDate;
@property (nonatomic, readonly, assign) RSDFDatePickerDate toDate;
@property (nonatomic, readonly, strong) UICollectionView *collectionView;
@property (nonatomic, readonly, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, readonly, strong) NSDate *today;

@end

@implementation RSDFDatePickerView

@synthesize calendar = _calendar;
@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize collectionView = _collectionView;
@synthesize collectionViewLayout = _collectionViewLayout;

- (void)configureCalendar
{
    _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *now = [_calendar dateFromComponents:[_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]]];
    
    _fromDate = [self pickerDateFromDate:[_calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        return components;
    })()) toDate:now options:0]];
    
    _toDate = [self pickerDateFromDate:[_calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = 6;
        return components;
    })()) toDate:now options:0]];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    _today = [calendar dateFromComponents:components];;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureCalendar];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    if (self) {
		[self configureCalendar];
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	self.collectionView.frame = self.bounds;
	if (!self.collectionView.superview) {
        if (self.collectionView.numberOfSections > 0) {
            RSDFDatePickerDate todayPickerDate = [self pickerDateFromDate:_today];
            NSInteger section = self.collectionView.numberOfSections / 2;
            NSDate *firstDayInMonth = [self dateForFirstDayInSection:section];
            NSUInteger weekday = [self.calendar components:NSWeekdayCalendarUnit fromDate:firstDayInMonth].weekday;
            
            // weekday start from 1 and include first day of month
            NSInteger item = weekday + todayPickerDate.day - 2;
            
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [self.collectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
		[self addSubview:self.collectionView];
	}
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	if (newSuperview && !_collectionView) {
		//	do some initialization!
		UICollectionView *cv = self.collectionView;
        [cv layoutIfNeeded];
	}
}

- (UICollectionView *)collectionView
{
	if (!_collectionView) {
		_collectionView = [[RSDFDatePickerCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionViewLayout];
		_collectionView.backgroundColor = [UIColor whiteColor];
		_collectionView.dataSource = self;
		_collectionView.delegate = self;
		_collectionView.showsVerticalScrollIndicator = NO;
		_collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.delaysContentTouches = NO;
		[_collectionView registerClass:[RSDFDatePickerDayCell class] forCellWithReuseIdentifier:DFDatePickerViewCellIdentifier];
		[_collectionView registerClass:[RSDFDatePickerMonthHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DFDatePickerViewMonthHeaderIdentifier];
        
		[_collectionView reloadData];
	}
	
	return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout
{
	//	Hard key these things.
	//	44 * 7 + 2 * 6 = 320; this is how the Calendar.app works
	//	and this also avoids the “one pixel” confusion which might or might not work
	//	If you need to decorate, key decorative views in.
	
	if (!_collectionViewLayout) {
		_collectionViewLayout = [UICollectionViewFlowLayout new];
		_collectionViewLayout.headerReferenceSize = (CGSize){ 320, 64 };
		_collectionViewLayout.itemSize = (CGSize){ 44, 70 };
		_collectionViewLayout.minimumLineSpacing = 2.0f;
		_collectionViewLayout.minimumInteritemSpacing = 2.0f;
	}
	
	return _collectionViewLayout;
}

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
	UICollectionView *cv = self.collectionView;
	UICollectionViewFlowLayout *cvLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
	
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
	
	NSInteger toSection = [self.calendar components:NSMonthCalendarUnit fromDate:[self dateForFirstDayInSection:0] toDate:fromSectionOfDate options:0].month;
	UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
	CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:cv];
	
	[cv setContentOffset:(CGPoint) {
		cv.contentOffset.x,
		cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
	}];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.calendar components:NSMonthCalendarUnit fromDate:[self dateFromPickerDate:self.fromDate] toDate:[self dateFromPickerDate:self.toDate] options:0].month;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 7 * [self numberOfWeeksForMonthOfDate:[self dateForFirstDayInSection:section]];
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
	
	return 1 + [self.calendar components:NSWeekCalendarUnit fromDate:fromSunday toDate:toSunday options:0].week;
}

- (RSDFDatePickerDayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	RSDFDatePickerDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DFDatePickerViewCellIdentifier forIndexPath:indexPath];
	
	NSDate *firstDayInMonth = [self dateForFirstDayInSection:indexPath.section];
	RSDFDatePickerDate firstDayPickerDate = [self pickerDateFromDate:firstDayInMonth];
	NSUInteger weekday = [self.calendar components:NSWeekdayCalendarUnit fromDate:firstDayInMonth].weekday;
	
	NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
		NSDateComponents *dateComponents = [NSDateComponents new];
		dateComponents.day = indexPath.item - (weekday - 1);
		return dateComponents;
	})()) toDate:firstDayInMonth options:0];
	RSDFDatePickerDate cellPickerDate = [self pickerDateFromDate:cellDate];
	
	cell.date = cellPickerDate;
    cell.dateLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)(cellPickerDate.day)];
    
	cell.enabled = ((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
    if (cell.enabled) {
        weekday = [self.calendar components:NSWeekdayCalendarUnit fromDate:cellDate].weekday;
        cell.dayOff = (weekday == 1) || (weekday == 7);
        
        NSDictionary *markedDates = [self.dataSource datePickerViewMarkedDates:self];
        NSNumber *markedDateState = [markedDates objectForKey:cellDate];
        if (markedDateState) {
            cell.marked = YES;
            cell.completed = [markedDateState boolValue];
        } else {
            cell.marked = NO;
            cell.completed = NO;
        }
        
        cell.today = ([cellDate compare:_today] == NSOrderedSame) ? YES : NO;
    }
    
	return cell;
}

//	We are cheating by piggybacking on view state to avoid recalculation
//	in -collectionView:shouldHighlightItemAtIndexPath:
//	and -collectionView:shouldSelectItemAtIndexPath:.

//	A native refactoring process might introduce duplicate state which is bad too.

- (BOOL) collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	RSDFDatePickerDayCell *cell = ((RSDFDatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]);
	NSDate *selectedDate = cell ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]] : nil;
    [self.delegate datePickerView:self didSelectDate:selectedDate];
    [self.collectionView reloadData];
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
		
		RSDFDatePickerMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:DFDatePickerViewMonthHeaderIdentifier forIndexPath:indexPath];
		
		NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:@"calendarMonthHeader" withConstructor:^{
			NSDateFormatter *dateFormatter = [NSDateFormatter new];
			dateFormatter.calendar = self.calendar;
			dateFormatter.dateFormat = @"MMM yyyy";
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
			return dateFormatter;
		}];
		
		NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
        RSDFDatePickerDate date = [self pickerDateFromDate:formattedDate];
        
        monthHeader.date = date;
        monthHeader.dateLabel.text = [[dateFormatter stringFromDate:formattedDate] uppercaseString];
		
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

- (NSDate *) dateFromPickerDate:(RSDFDatePickerDate)dateStruct
{
	return [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:dateStruct]];
}

- (NSDateComponents *) dateComponentsFromPickerDate:(RSDFDatePickerDate)dateStruct
{
	NSDateComponents *components = [NSDateComponents new];
	components.year = dateStruct.year;
	components.month = dateStruct.month;
	components.day = dateStruct.day;
	return components;
}

- (RSDFDatePickerDate) pickerDateFromDate:(NSDate *)date
{
	NSDateComponents *components = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
	return (RSDFDatePickerDate) {
		components.year,
		components.month,
		components.day
	};
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

@end

#import "RSDFDatePickerDaysOfWeekView.h"
#import "NSCalendar+RSDFAdditions.h"

@interface RSDFDatePickerDaysOfWeekView ()

@property (strong, nonatomic) NSCalendar *calendar;

@end

@implementation RSDFDatePickerDaysOfWeekView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:frame];
    if (self) {
        _calendar = calendar;
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

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

#pragma mark - Custom Accessors

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    return _calendar;
}

#pragma mark - Private

- (void)commonInitializer
{
    self.backgroundColor = [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0];
    
    UIColor *weekdayLabelBackgroundColor = [UIColor clearColor];
    UIFont *weekdayLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    UIColor *weekdayLabelDayTextColor = [UIColor blackColor];
    UIColor *weekdayLabelDayOffTextColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
    
    //	Hard key these things.
    //	44 * 7 + 2 * 6 = 320; from collectionViewLayout of RSDFDatePickerView
    
    CGFloat dayItemWidth = 44.0f;
    CGFloat minimumInteritemSpacing = 2.0f;
    
    CGFloat yCenter = CGRectGetHeight(self.bounds) / 2;
    __block CGFloat xCenter = dayItemWidth / 2;
    
    NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:@"calendarDaysOfWeekView" withConstructor:^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.calendar = self.calendar;
        dateFormatter.locale = [self.calendar locale];
        return dateFormatter;
    }];
    
    NSArray *weekdaySymbols = [dateFormatter veryShortStandaloneWeekdaySymbols];
    NSArray *reorderedWeekdaySymbols = nil;
    
    // weekday start from 1
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        reorderedWeekdaySymbols = [[weekdaySymbols subarrayWithRange:NSMakeRange(firstWeekdayIndex, [weekdaySymbols count] - firstWeekdayIndex)]
                                   arrayByAddingObjectsFromArray:[weekdaySymbols subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    } else {
        reorderedWeekdaySymbols = weekdaySymbols;
    }
    
    [reorderedWeekdaySymbols enumerateObjectsUsingBlock:^(NSString *weekdaySymbol, NSUInteger idx, BOOL *stop) {
        UILabel *weekdayLabel = [[UILabel alloc] init];
        weekdayLabel.backgroundColor = weekdayLabelBackgroundColor;
        weekdayLabel.font = weekdayLabelFont;
        if ([weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 0 && [weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 6) {
            weekdayLabel.textColor = weekdayLabelDayTextColor;
        } else {
            weekdayLabel.textColor = weekdayLabelDayOffTextColor;
        }
        weekdayLabel.text = weekdaySymbol;
        [weekdayLabel sizeToFit];
        weekdayLabel.center = CGPointMake(xCenter, yCenter);
        [self addSubview:weekdayLabel];
        
        xCenter += (dayItemWidth + minimumInteritemSpacing);
    }];
}

@end

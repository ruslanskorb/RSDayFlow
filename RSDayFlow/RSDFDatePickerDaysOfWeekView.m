#import "RSDFDatePickerDaysOfWeekView.h"
#import "NSCalendar+RSDFAdditions.h"

@interface RSDFDatePickerDaysOfWeekView ()

@property (strong, nonatomic) NSCalendar *calendar;

@end

@implementation RSDFDatePickerDaysOfWeekView

#pragma mark - Lifecycle

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

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:frame];
    if (self) {
        _calendar = calendar;
        [self commonInitializer];
    }
    return self;
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

#pragma mark - Private

- (void)commonInitializer
{
    self.backgroundColor = [self selfBackgroundColor];
    
    UIColor *dayOfWeekLabelBackgroundColor = [UIColor clearColor];
    UIFont *dayOfWeekLabelFont = [self dayOfWeekLabelFont];
    UIColor *dayOfWeekLabelTextColor = [self dayOfWeekLabelTextColor];
    UIColor *dayOffOfWeekLabelTextColor = [self dayOffOfWeekLabelTextColor];
    
    //	Hard key these things.
    //	44 * 7 + 2 * 6 = 320; in accordance with RSDFDatePickerCollectionViewLayout
    
    CGSize itemSize = [self selfItemSize];
    CGFloat interitemSpacing = [self selfInteritemSpacing];
    
    CGFloat y = 0;
    __block CGFloat x = 0;
    
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
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, itemSize.width, itemSize.height)];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.backgroundColor = dayOfWeekLabelBackgroundColor;
        weekdayLabel.font = dayOfWeekLabelFont;
        if ([weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 0 && [weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 6) {
            weekdayLabel.textColor = dayOfWeekLabelTextColor;
        } else {
            weekdayLabel.textColor = dayOffOfWeekLabelTextColor;
        }
        weekdayLabel.text = weekdaySymbol;
        [self addSubview:weekdayLabel];
        
        x += (itemSize.width + interitemSpacing);
    }];
}

#pragma mark - Attributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0];
}

#pragma mark - Attributes of the Layout

- (CGSize)selfItemSize
{
    return (CGSize){ 44, 22 };
}

- (CGFloat)selfInteritemSpacing
{
    return 2.0f;
}

#pragma mark - Attributes of Subviews

- (UIFont *)dayOfWeekLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
}

- (UIColor *)dayOfWeekLabelTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)dayOffOfWeekLabelTextColor
{
    return [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
}

@end

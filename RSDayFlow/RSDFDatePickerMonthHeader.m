#import "RSDFDatePickerMonthHeader.h"

@implementation RSDFDatePickerMonthHeader

@synthesize dateLabel = _dateLabel;

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

- (void)commonInitializer
{
    self.backgroundColor = [self selfBackgroundColor];
}

#pragma mark - Custom Accessors

- (UILabel *)dateLabel
{
	if (!_dateLabel) {
		_dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.opaque = NO;
		_dateLabel.textAlignment = NSTextAlignmentCenter;
		_dateLabel.font = [self monthLabelFont];
		_dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_dateLabel];
	}
	return _dateLabel;
}

- (void)setDate:(RSDFDatePickerDate)date
{
    _date = date;
}

- (void)setCurrentMonth:(BOOL)currentMonth
{
    _currentMonth = currentMonth;
    if (!_currentMonth) {
        self.dateLabel.textColor = [self monthLabelTextColor];
    } else {
        self.dateLabel.textColor = [self currentMonthLabelTextColor];
    }
}

#pragma mark - Attributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor clearColor];
}

#pragma mark - Attributes of Subviews

- (UIFont *)monthLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
}

- (UIColor *)monthLabelTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)currentMonthLabelTextColor
{
    return [UIColor colorWithRed:32/255.0f green:135/255.0f blue:252/255.0f alpha:1.0f];
}

@end

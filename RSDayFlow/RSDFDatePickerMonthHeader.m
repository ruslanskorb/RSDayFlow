#import "RSDFDatePickerMonthHeader.h"

@implementation RSDFDatePickerMonthHeader

@synthesize dateLabel = _dateLabel;

- (UILabel *)dateLabel
{
	if (!_dateLabel) {
		_dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
		_dateLabel.textAlignment = NSTextAlignmentCenter;
		_dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
		_dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
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
    if (_currentMonth) {
        self.dateLabel.textColor = [UIColor colorWithRed:32/255.0f green:135/255.0f blue:252/255.0f alpha:1.0f];
    } else {
        self.dateLabel.textColor = [UIColor blackColor];
    }
}

@end

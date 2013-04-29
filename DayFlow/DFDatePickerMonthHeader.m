#import "DFDatePickerMonthHeader.h"

@implementation DFDatePickerMonthHeader
@synthesize textLabel = _textLabel;

- (UILabel *) textLabel {
	if (!_textLabel) {
		_textLabel = [[UILabel alloc] initWithFrame:self.bounds];
		_textLabel.textAlignment = NSTextAlignmentCenter;
		_textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
		_textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self addSubview:_textLabel];
	}
	return _textLabel;
}

@end

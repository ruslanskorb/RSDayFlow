#import "DFDatePickerDayCell.h"

@interface DFDatePickerDayCell ()
+ (NSCache *) imageCache;
+ (id) cacheKeyForPickerDate:(DFDatePickerDate)date;
+ (id) fetchObjectForKey:(id)key withCreator:(id(^)(void))block;
@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIView *overlayView;
@end

@implementation DFDatePickerDayCell
@synthesize imageView = _imageView;
@synthesize overlayView = _overlayView;

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void) setDate:(DFDatePickerDate)date {
	_date = date;
	[self setNeedsLayout];
}

- (void) setEnabled:(BOOL)enabled {
	_enabled = enabled;
	[self setNeedsLayout];
}

- (void) setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	[self setNeedsLayout];
}
- (void) setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self setNeedsLayout];
}

- (void) layoutSubviews {
	
	[super layoutSubviews];
	
	//	Instead of using labels, use images keyed by day.
	//	This avoids redrawing text within labels, which involve lots of parts of
	//	WebCore and CoreGraphics, and makes sure scrolling is always smooth.
	
	//	Reason: when the view is first shown, all common days are drawn once and cached.
	//	Memory pressure is also low.
	
	//	Note: Assumption! If there is a calendar with unique day names
	//	we will be in big trouble. If there is one odd month with 1000 days we will
	//	also be in some sort of trouble. But for most use cases we are probably good.
	
	//	We still have DFDatePickerMonthHeader take a NSDateFormatter formatted title
	//	and draw it, but since that’s only one bitmap instead of 35-odd (7 weeks)
	//	that’s mostly okay.
	
	self.imageView.alpha = self.enabled ? 1.0f : 0.25f;
	
	self.imageView.image = [[self class] fetchObjectForKey:[[self class] cacheKeyForPickerDate:self.date] withCreator:^{
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.window.screen.scale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		
#if 0
		
		//	Generate a random color
		//	https://gist.github.com/kylefox/1689973
		CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
		CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
		CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
		CGContextSetFillColorWithColor(context, [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f].CGColor);
		
#else
		
		CGContextSetFillColorWithColor(context, [UIColor colorWithRed:53.0f/256.0f green:145.0f/256.0f blue:195.0f/256.0f alpha:1.0f].CGColor);
		
#endif

		CGContextFillRect(context, self.bounds);
		
		UIFont *font = [UIFont boldSystemFontOfSize:20.0f];
		CGRect textBounds = (CGRect){ 0.0f, 10.0f, 44.0f, 24.0f };
		
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		[[NSString stringWithFormat:@"%i", self.date.day] drawInRect:textBounds withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
		
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
		
	}];
	
	self.overlayView.hidden = !(self.selected || self.highlighted);

}

- (UIView *) overlayView {
	if (!_overlayView) {
		_overlayView = [[UIView alloc] initWithFrame:self.contentView.bounds];
		_overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_overlayView.backgroundColor = [UIColor blackColor];
		_overlayView.alpha = 0.25f;
		[self.contentView addSubview:_overlayView];
	}
	return _overlayView;
}

- (UIImageView *) imageView {
	if (!_imageView) {
		_imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:_imageView];
	}
	return _imageView;
}

+ (NSCache *) imageCache {
	static NSCache *cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [NSCache new];
	});
	return cache;
}

+ (id) cacheKeyForPickerDate:(DFDatePickerDate)date {
	return @(date.day);
}

+ (id) fetchObjectForKey:(id)key withCreator:(id(^)(void))block {
	id answer = [[self imageCache] objectForKey:key];
	if (!answer) {
		answer = block();
		[[self imageCache] setObject:answer forKey:key];
	}
	return answer;
}

@end

#import "RSDFDatePickerDayCell.h"

@interface RSDFDatePickerDayCell ()

+ (NSCache *)imageCache;
+ (id)fetchObjectForKey:(id)key withCreator:(id(^)(void))block;

@property (nonatomic, readonly, strong) UIImageView *dividerTopImageView;
@property (nonatomic, readonly, strong) UIImageView *markerImageView;
@property (nonatomic, readonly, strong) UIImageView *overlayImageView;
@property (nonatomic, readonly, strong) UIImageView *todayImageView;

@end

@implementation RSDFDatePickerDayCell

@synthesize dateLabel           = _dateLabel;
@synthesize dividerTopImageView = _dividerTopImageView;
@synthesize markerImageView     = _markerImageView;
@synthesize overlayImageView    = _overlayImageView;
@synthesize todayImageView      = _todayImageView;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInitializer];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (void)commonInitializer
{
    self.backgroundColor = [UIColor whiteColor];
    self.todayImageView.hidden      = YES;
    self.overlayImageView.hidden    = YES;
    self.markerImageView.hidden     = YES;
    self.dividerTopImageView.hidden = NO;
    self.dateLabel.hidden           = NO;
}

- (void)setDate:(RSDFDatePickerDate)date
{
    _date = date;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    if (!_enabled) {
        self.todayImageView.hidden  = YES;
        self.markerImageView.hidden = YES;
    }
    self.dateLabel.hidden           = !_enabled;
    self.dividerTopImageView.hidden = !_enabled;
}

- (void)setDayOff:(BOOL)dayOff
{
    _dayOff = dayOff;
    if (!_dayOff) {
        self.dateLabel.textColor = [UIColor blackColor];
    } else {
        self.dateLabel.textColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
    }
}

- (void)setMarked:(BOOL)marked
{
    _marked = marked;
    self.markerImageView.hidden = !_marked;
}

- (void)setCompleted:(BOOL)completed
{
    _completed = completed;
    if (_completed) {
        self.markerImageView.image = [[self class] fetchObjectForKey:@"img_marker_green" withCreator:^id{
            UIGraphicsBeginImageContextWithOptions(_markerImageView.frame.size, NO, self.window.screen.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGRect rect = _markerImageView.frame;
            rect.origin = CGPointZero;
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:83/255.0f green:215/255.0f blue:105/255.0f alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, rect);
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return image;
        }];
    } else {
        self.markerImageView.image = [[self class] fetchObjectForKey:@"img_marker_gray" withCreator:^id{
            UIGraphicsBeginImageContextWithOptions(_markerImageView.frame.size, NO, self.window.screen.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGRect rect = _markerImageView.frame;
            rect.origin = CGPointZero;
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, rect);
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return image;
        }];
    }
}

- (void)setToday:(BOOL)today
{
    _today = today;
    if (!_today) {
        self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    } else {
        self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f];
        self.dateLabel.textColor = [UIColor whiteColor];
    }
    self.todayImageView.hidden = !_today;
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	self.overlayImageView.hidden = !(self.highlighted);
}

- (UIImageView *)todayImageView
{
    if (!_todayImageView) {
        CGRect frame = CGRectMake(0.0f, 0.0f, 35.0f, 35.0f);
        _todayImageView = [[UIImageView alloc] initWithFrame:frame];
        _todayImageView.center = CGPointMake(self.frame.size.width/2, 23.0f);
        _todayImageView.backgroundColor = [UIColor clearColor];
        
        _todayImageView.image = [[self class] fetchObjectForKey:@"img_today" withCreator:^id{
            UIGraphicsBeginImageContextWithOptions(_todayImageView.frame.size, NO, self.window.screen.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGRect rect = _todayImageView.frame;
            rect.origin = CGPointZero;
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0/255.0f green:121/255.0f blue:255/255.0f alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, rect);
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return image;
        }];
        
        [self.contentView addSubview:_todayImageView];
    }
    return _todayImageView;
}

- (UIImageView *)dividerTopImageView
{
	if (!_dividerTopImageView) {
        CGRect frame = CGRectMake(0.0f, 0.0f, 50.0f, 0.5f);
        _dividerTopImageView = [[UIImageView alloc] initWithFrame:frame];
        
        _dividerTopImageView.image = [[self class] fetchObjectForKey:@"img_divider_top" withCreator:^id{
            UIGraphicsBeginImageContextWithOptions(_dividerTopImageView.frame.size, NO, self.window.screen.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0f].CGColor);
            CGContextFillRect(context, _dividerTopImageView.frame);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image;
        }];
        
		[self.contentView addSubview:_dividerTopImageView];
	}
	return _dividerTopImageView;
}

- (UIImageView *)overlayImageView
{
	if (!_overlayImageView) {
        _overlayImageView = [[UIImageView alloc] initWithFrame:self.todayImageView.frame];
        
        _overlayImageView.image = [[self class] fetchObjectForKey:@"img_overlay" withCreator:^id{
            UIGraphicsBeginImageContextWithOptions(_overlayImageView.frame.size, NO, self.window.screen.scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGRect rect = _overlayImageView.frame;
            rect.origin = CGPointZero;
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, rect);
            
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return image;
        }];
        
        _overlayImageView.opaque = YES;
        _overlayImageView.alpha = 0.5f;
        [self.contentView addSubview:_overlayImageView];
	}
	return _overlayImageView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        CGRect frame = CGRectMake(self.bounds.origin.x,
                                  self.todayImageView.frame.origin.y,
                                  self.bounds.size.width,
                                  self.todayImageView.frame.size.height);
        _dateLabel = [[UILabel alloc] initWithFrame:frame];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIImageView *)markerImageView
{
    if (!_markerImageView) {
        CGRect frame = CGRectMake(0.0f, 0.0f, 9.0f, 9.0f);
        _markerImageView = [[UIImageView alloc] initWithFrame:frame];
        CGFloat centerX = self.frame.size.width / 2;
        CGFloat centerY = 50.0f;
        _markerImageView.center = CGPointMake(centerX, centerY);
        [self.contentView addSubview:_markerImageView];
    }
    return _markerImageView;
}

+ (NSCache *)imageCache
{
	static NSCache *cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [NSCache new];
	});
	return cache;
}

+ (id)fetchObjectForKey:(id)key withCreator:(id(^)(void))block
{
	id answer = [[self imageCache] objectForKey:key];
	if (!answer) {
		answer = block();
		[[self imageCache] setObject:answer forKey:key];
	}
	return answer;
}

@end

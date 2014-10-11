//
// RSDFDatePickerDayCell.m
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

#import "RSDFDatePickerDayCell.h"

@interface RSDFDatePickerDayCell ()

+ (NSCache *)imageCache;
+ (id)fetchObjectForKey:(id)key withCreator:(id(^)(void))block;

@property (nonatomic, readonly, strong) UIImageView *todayImageView;
@property (nonatomic, readonly, strong) UIImageView *overlayImageView;
@property (nonatomic, readonly, strong) UIImageView *markImageView;
@property (nonatomic, readonly, strong) UIImageView *dividerImageView;

@end

@implementation RSDFDatePickerDayCell

@synthesize dateLabel = _dateLabel;
@synthesize todayImageView = _todayImageView;
@synthesize overlayImageView = _overlayImageView;
@synthesize markImageView = _markImageView;
@synthesize dividerImageView = _dividerImageView;

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
    
    self.todayImageView.hidden = YES;
    self.overlayImageView.hidden = YES;
    self.markImageView.hidden = YES;
    self.dividerImageView.hidden = NO;
    self.dateLabel.hidden = NO;
    
    [self addSubview:self.todayImageView];
    [self addSubview:self.overlayImageView];
    [self addSubview:self.markImageView];
    [self addSubview:self.dividerImageView];
    [self addSubview:self.dateLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.dateLabel.frame = [self todayImageViewFrame];
    self.todayImageView.frame = [self todayImageViewFrame];
    self.overlayImageView.frame = [self todayImageViewFrame];
    self.markImageView.frame = [self markImageViewFrame];
    self.dividerImageView.frame = [self dividerImageViewFrame];
    self.dividerImageView.image = [self dividerImage];
}

#pragma mark - Custom Accessors

- (void)setDate:(RSDFDatePickerDate)date
{
    _date = date;
}

- (void)setNotThisMonth:(BOOL)notThisMonth
{
    _notThisMonth = notThisMonth;
    if (_notThisMonth) {
        self.dateLabel.textColor = [self notThisMonthLabelTextColor];
        self.dateLabel.font = [self dayLabelFont];
        self.todayImageView.hidden = YES;
        self.markImageView.hidden = YES;
        self.dividerImageView.hidden = YES;
    } else {
        if (!self.isDayOff) {
            self.dateLabel.textColor = [self dayLabelTextColor];
        } else {
            self.dateLabel.textColor = [self dayOffLabelTextColor];
        }
        if (!self.isToday) {
            self.dateLabel.font = [self dayLabelFont];
        } else {
            self.dateLabel.font = [self todayLabelFont];
        }
        self.todayImageView.hidden = !self.today;
        self.markImageView.hidden = !self.marked;
        self.dividerImageView.hidden = NO;
    }
}

- (void)setDayOff:(BOOL)dayOff
{
    _dayOff = dayOff;
    if (!_dayOff) {
        self.dateLabel.textColor = [self dayLabelTextColor];
    } else {
        self.dateLabel.textColor = [self dayOffLabelTextColor];
    }
}

- (void)setMarked:(BOOL)marked
{
    _marked = marked;
    self.markImageView.hidden = !_marked;
}

- (void)setCompleted:(BOOL)completed
{
    _completed = completed;
    if (!_completed) {
        self.markImageView.image = [self incompleteMarkImage];
    } else {
        self.markImageView.image = [self completeMarkImage];
    }
}

- (void)setToday:(BOOL)today
{
    _today = today;
    if (!_today) {
        self.dateLabel.font = [self dayLabelFont];
        if (!self.dayOff) {
            self.dateLabel.textColor = [self dayLabelTextColor];
        } else {
            self.dateLabel.textColor = [self dayOffLabelTextColor];
        }
    } else {
        self.dateLabel.font = [self todayLabelFont];
        self.dateLabel.textColor = [self todayLabelTextColor];
    }
    self.todayImageView.hidden = !_today;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.overlayImageView.hidden = !self.highlighted;
}

- (CGRect)todayImageViewFrame
{
    return CGRectMake(CGRectGetWidth(self.frame) / 2 - 17.5f, 5.5f, 35.0f, 35.0f);
}

- (UIImageView *)todayImageView
{
    if (!_todayImageView) {
        _todayImageView = [[UIImageView alloc] initWithFrame:[self todayImageViewFrame]];
        _todayImageView.backgroundColor = [UIColor clearColor];
        _todayImageView.contentMode = UIViewContentModeCenter;
        _todayImageView.image = [self todayImage];
    }
    return _todayImageView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:[self todayImageViewFrame]];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

- (UIImageView *)overlayImageView
{
    if (!_overlayImageView) {
        _overlayImageView = [[UIImageView alloc] initWithFrame:[self todayImageViewFrame]];
        _overlayImageView.backgroundColor = [UIColor clearColor];
        _overlayImageView.opaque = NO;
        _overlayImageView.alpha = 0.5f;
        _overlayImageView.contentMode = UIViewContentModeCenter;
        _overlayImageView.image = [self overlayImage];
    }
    return _overlayImageView;
}

- (CGRect)markImageViewFrame
{
    return CGRectMake(CGRectGetWidth(self.frame) / 2 - 4.5f, 45.5f, 9.0f, 9.0f);
}

- (UIImageView *)markImageView
{
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] initWithFrame:[self markImageViewFrame]];
        _markImageView.backgroundColor = [UIColor clearColor];
        _markImageView.contentMode = UIViewContentModeCenter;
        _markImageView.image = [self incompleteMarkImage];
    }
    return _markImageView;
}

- (CGRect)dividerImageViewFrame
{
    return CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame) + 3.0f, 0.5f);
}

- (UIImageView *)dividerImageView
{
    if (!_dividerImageView) {
        _dividerImageView = [[UIImageView alloc] initWithFrame:[self dividerImageViewFrame]];
        _dividerImageView.contentMode = UIViewContentModeCenter;
        _dividerImageView.image = [self dividerImage];
    }
    return _dividerImageView;
}

#pragma mark - Private

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

- (UIImage *)ellipseImageWithKey:(NSString *)key frame:(CGRect)frame color:(UIColor *)color
{
    UIImage *ellipseImage = [[self class] fetchObjectForKey:key withCreator:^id{
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, self.window.screen.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGRect rect = frame;
        rect.origin = CGPointZero;
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, rect);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }];
    return ellipseImage;
}

- (UIImage *)rectImageWithKey:(NSString *)key frame:(CGRect)frame color:(UIColor *)color
{
    UIImage *rectImage = [[self class] fetchObjectForKey:key withCreator:^id{
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, self.window.screen.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, frame);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }];
    return rectImage;
}

#pragma mark - Atrributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor clearColor];
}

#pragma mark - Attributes of Subviews

- (UIFont *)dayLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
}

- (UIColor *)dayLabelTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)dayOffLabelTextColor
{
    return [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
}

- (UIColor *)notThisMonthLabelTextColor
{
    return [UIColor clearColor];
}

- (UIFont *)todayLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f];
}

- (UIColor *)todayLabelTextColor
{
    return [UIColor whiteColor];;
}

- (UIColor *)todayImageColor
{
    return [UIColor colorWithRed:0/255.0f green:121/255.0f blue:255/255.0f alpha:1.0f];
}

- (UIImage *)customTodayImage
{
    return nil;
}

- (UIImage *)todayImage
{
    UIImage *todayImage = [self customTodayImage];
    if (!todayImage) {
        UIColor *todayImageColor = [self todayImageColor];
        NSString *todayImageKey = [NSString stringWithFormat:@"img_today_%@", [todayImageColor description]];
        todayImage = [self ellipseImageWithKey:todayImageKey frame:self.todayImageView.frame color:todayImageColor];
    }
    return todayImage;
}

- (UIColor *)overlayImageColor
{
    return [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
}

- (UIImage *)customOverlayImage
{
    return nil;
}

- (UIImage *)overlayImage
{
    UIImage *overlayImage = [self customOverlayImage];
    if (!overlayImage) {
        UIColor *overlayImageColor = [self overlayImageColor];
        NSString *overlayImageKey = [NSString stringWithFormat:@"img_overlay_%@", [overlayImageColor description]];
        overlayImage = [self ellipseImageWithKey:overlayImageKey frame:self.overlayImageView.frame color:overlayImageColor];
    }
    return overlayImage;
}

- (UIColor *)incompleteMarkImageColor
{
    return [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
}

- (UIImage *)customIncompleteMarkImage
{
    return nil;
}

- (UIImage *)incompleteMarkImage
{
    UIImage *incompleteMarkImage = [self customIncompleteMarkImage];
    if (!incompleteMarkImage) {
        UIColor *incompleteMarkImageColor = [self incompleteMarkImageColor];
        NSString *incompleteMarkImageKey = [NSString stringWithFormat:@"img_mark_%@", [incompleteMarkImageColor description]];
        incompleteMarkImage = [self ellipseImageWithKey:incompleteMarkImageKey frame:self.markImageView.frame color:incompleteMarkImageColor];
    }
    return incompleteMarkImage;
}

- (UIColor *)completeMarkImageColor
{
    return [UIColor colorWithRed:83/255.0f green:215/255.0f blue:105/255.0f alpha:1.0f];
}

- (UIImage *)customCompleteMarkImage
{
    return nil;
}

- (UIImage *)completeMarkImage
{
    UIImage *completeMarkImage = [self customCompleteMarkImage];
    if (!completeMarkImage) {
        UIColor *completeMarkImageColor = [self completeMarkImageColor];
        NSString *completeMarkImageKey = [NSString stringWithFormat:@"img_mark_%@", [completeMarkImageColor description]];
        completeMarkImage = [self ellipseImageWithKey:completeMarkImageKey frame:self.markImageView.frame color:completeMarkImageColor];
    }
    return completeMarkImage;
}

- (UIColor *)dividerImageColor
{
    return [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0f];
}

- (UIImage *)customDividerImage
{
    return nil;
}

- (UIImage *)dividerImage
{
    UIImage *dividerImage = [self customDividerImage];
    if (!dividerImage) {
        UIColor *dividerImageColor = [self dividerImageColor];
        NSString *dividerImageKey = [NSString stringWithFormat:@"img_divider_%@_%g", [dividerImageColor description], CGRectGetWidth(self.dividerImageView.frame)];
        dividerImage = [self rectImageWithKey:dividerImageKey frame:self.dividerImageView.frame color:dividerImageColor];
    }
    return dividerImage;
}

@end

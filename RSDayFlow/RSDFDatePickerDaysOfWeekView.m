#import "RSDFDatePickerDaysOfWeekView.h"

@implementation RSDFDatePickerDaysOfWeekView

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
    self.backgroundColor = [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    UIColor *dayColor = [UIColor blackColor];
    UIColor *dayOffColor = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
    CGFloat yCenter = CGRectGetHeight(self.bounds) / 2;
    
    //	Hard key these things.
	//	44 * 7 + 2 * 6 = 320; from collectionViewLayout of RSDFDatePickerView
    
    CGFloat dayItemWidth = 44.0f;
    CGFloat minimumInteritemSpacing = 2.0f;
    
    UILabel *sunday = [[UILabel alloc] init];
    sunday.font = font;
    sunday.text = @"S";
    sunday.textColor = dayOffColor;
    [sunday sizeToFit];
    CGFloat xCenter = dayItemWidth / 2;
    sunday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:sunday];
    
    UILabel *monday = [[UILabel alloc] init];
    monday.font = font;
    monday.text = @"M";
    monday.textColor = dayColor;
    [monday sizeToFit];
    xCenter += (dayItemWidth + minimumInteritemSpacing);
    monday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:monday];
    
    UILabel *tuesday = [[UILabel alloc] init];
    tuesday.font = font;
    tuesday.text = @"T";
    tuesday.textColor = dayColor;
    [tuesday sizeToFit];
    xCenter += (dayItemWidth + minimumInteritemSpacing);
    tuesday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:tuesday];
    
    UILabel *wednesday = [[UILabel alloc] init];
    wednesday.font = font;
    wednesday.text = @"W";
    wednesday.textColor = dayColor;
    [wednesday sizeToFit];
    xCenter += (dayItemWidth + minimumInteritemSpacing);
    wednesday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:wednesday];
    
    UILabel *thursday = [[UILabel alloc] init];
    thursday.font = font;
    thursday.text = @"T";
    thursday.textColor = dayColor;
    [thursday sizeToFit];
    xCenter += (dayItemWidth + minimumInteritemSpacing);
    thursday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:thursday];
    
    UILabel *friday = [[UILabel alloc] init];
    friday.font = font;
    friday.text = @"F";
    friday.textColor = dayColor;
    [friday sizeToFit];
    xCenter += (dayItemWidth + minimumInteritemSpacing);
    friday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:friday];
    
    UILabel *saturday = [[UILabel alloc] init];
    saturday.font = font;
    saturday.text = @"S";
    saturday.textColor = dayOffColor;
    [saturday sizeToFit];
    xCenter += (dayItemWidth + minimumInteritemSpacing);
    saturday.center = CGPointMake(xCenter, yCenter);
    [self addSubview:saturday];
}

@end

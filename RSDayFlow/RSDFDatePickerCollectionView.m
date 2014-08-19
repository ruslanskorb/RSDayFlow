#import "RSDFDatePickerCollectionView.h"
#import "RSDFDatePickerCollectionViewLayout.h"

@implementation RSDFDatePickerCollectionView

@dynamic delegate;

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

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (void)commonInitializer
{
    self.backgroundColor = [self selfBackgroundColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.scrollsToTop = NO;
    self.delaysContentTouches = NO;
}

- (void)layoutSubviews
{
    if ([self.delegate respondsToSelector:@selector(pickerCollectionViewWillLayoutSubviews:)]) {
        [self.delegate pickerCollectionViewWillLayoutSubviews:self];
    }
	[super layoutSubviews];
}

#pragma mark - Atrributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor whiteColor];
}

@end

#import "RSDFDatePickerCollectionViewLayout.h"

@implementation RSDFDatePickerCollectionViewLayout

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
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
    //	Hard key these things.
    //	44 * 7 + 2 * 6 = 320; this is how the Calendar.app works
    //	and this also avoids the “one pixel” confusion which might or might not work
    //	If you need to decorate, key decorative views in.
    
    self.headerReferenceSize = [self selfHeaderReferenceSize];
    self.itemSize = [self selfItemSize];
    self.minimumLineSpacing = [self selfMinimumLineSpacing];
    self.minimumInteritemSpacing = [self selfMinimumInteritemSpacing];
}

#pragma mark - Atrributes of the Layout

- (CGSize)selfHeaderReferenceSize
{
    return (CGSize){ 320, 64 };
}

- (CGSize)selfItemSize
{
    return (CGSize){ 44, 70 };
}

- (CGFloat)selfMinimumLineSpacing
{
    return 2.0f;
}

- (CGFloat)selfMinimumInteritemSpacing
{
    return 2.0f;
}

@end

#import "RSDFDatePickerCollectionView.h"

@implementation RSDFDatePickerCollectionView

@dynamic delegate;

- (void)layoutSubviews
{
    if ([self.delegate respondsToSelector:@selector(pickerCollectionViewWillLayoutSubviews:)]) {
        [self.delegate pickerCollectionViewWillLayoutSubviews:self];
    }
	[super layoutSubviews];
}

@end

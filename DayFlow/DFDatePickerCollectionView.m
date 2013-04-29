#import "DFDatePickerCollectionView.h"

@implementation DFDatePickerCollectionView
@dynamic delegate;

- (void) layoutSubviews {
	
	[self.delegate pickerCollectionViewWillLayoutSubviews:self];
	[super layoutSubviews];
		
}

@end

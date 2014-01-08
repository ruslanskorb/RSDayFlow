#import <UIKit/UIKit.h>

@class RSDFDatePickerCollectionView;

@protocol RSDFDatePickerCollectionViewDelegate <UICollectionViewDelegate>

- (void) pickerCollectionViewWillLayoutSubviews:(RSDFDatePickerCollectionView *)pickerCollectionView;

@end

@interface RSDFDatePickerCollectionView : UICollectionView

@property (nonatomic, assign) id <RSDFDatePickerCollectionViewDelegate> delegate;

@end

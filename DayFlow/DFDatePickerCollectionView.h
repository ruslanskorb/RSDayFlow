#import <UIKit/UIKit.h>

@class DFDatePickerCollectionView;
@protocol DFDatePickerCollectionViewDelegate <UICollectionViewDelegate>

- (void) pickerCollectionViewWillLayoutSubviews:(DFDatePickerCollectionView *)pickerCollectionView;

@end

@interface DFDatePickerCollectionView : UICollectionView

@property (nonatomic, assign) id <DFDatePickerCollectionViewDelegate> delegate;

@end

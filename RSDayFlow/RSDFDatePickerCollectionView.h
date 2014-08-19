#import <UIKit/UIKit.h>

@class RSDFDatePickerCollectionView;

/**
 The `RSDFDatePickerCollectionViewDelegate` protocol defines the message sent to a collection view delegate when the collection view will layout subviews.
 */
@protocol RSDFDatePickerCollectionViewDelegate <UICollectionViewDelegate>

///---------------------------------
/// @name Supporting Layout Subviews
///---------------------------------

/**
 Tells the delegate that the collection view will layout subviews.
 
 @param pickerCollectionView The collection view which will layout subviews.
 */
- (void) pickerCollectionViewWillLayoutSubviews:(RSDFDatePickerCollectionView *)pickerCollectionView;

@end


/**
 The `RSDFDatePickerCollectionView` is a collection view which used to display days and months in the date picker view.
 */
@interface RSDFDatePickerCollectionView : UICollectionView

/**
 The receiver's delegate.
 
 @discussion A `RSDFDatePickerCollectionView` delegate uses to support layout subviews in the date picker view.
 */
@property (nonatomic, assign) id <RSDFDatePickerCollectionViewDelegate> delegate;

///---------------------------------------
/// @name Accessing Attributes of the View
///---------------------------------------

/**
 The view’s background color. Default value is `[UIColor whiteColor]`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)selfBackgroundColor;

@end

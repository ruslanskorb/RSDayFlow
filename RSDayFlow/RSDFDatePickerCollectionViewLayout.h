#import <UIKit/UIKit.h>

/**
 The `RSDFDatePickerCollectionViewLayout` is a layout of the collection view which used the date picker.
 */
@interface RSDFDatePickerCollectionViewLayout : UICollectionViewFlowLayout

///-----------------------------------------
/// @name Accessing Attributes of the Layout
///-----------------------------------------

/**
 The default sizes to use for section headers. Default value is {320, 64}.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (CGSize)selfHeaderReferenceSize;

/**
 The default size to use for cells. Default value is {44, 70}.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (CGSize)selfItemSize;

/**
 The minimum spacing to use between lines of items in the grid. Default value is `2.0f`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (CGFloat)selfMinimumLineSpacing;

/**
 The minimum spacing to use between items in the same row. Default value is `2.0f`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (CGFloat)selfMinimumInteritemSpacing;

@end

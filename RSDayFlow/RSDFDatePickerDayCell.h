#import <UIKit/UIKit.h>
#import "RSDayFlow.h"

/**
 The `RSDFDatePickerDayCell` is a cell which used to display a day in the date picker view.
 */
@interface RSDFDatePickerDayCell : UICollectionViewCell

///-------------------------
/// @name Accessing Subviews
///-------------------------

/**
 The label showing the cell's date.
 */
@property (nonatomic, readonly, strong) UILabel *dateLabel;

///--------------------------------------
/// @name Accessing Attributes of the Day
///--------------------------------------

/**
 A date which corresponds to the current cell.
 */
@property (nonatomic, readwrite, assign) RSDFDatePickerDate date;

/**
 A Boolean value that determines whether the cell's day is enabled.
 
 @discussion Cells with inactive days do not display the content.
*/
@property (nonatomic, getter = isEnabled) BOOL enabled;

/**
 A Boolean value that determines whether the cell's day is day off.
 */
@property (nonatomic, getter = isDayOff) BOOL dayOff;

/**
 A Boolean value that determines whether the cell represents the current day.
 */
@property (nonatomic, getter = isToday) BOOL today;

/**
 A Boolean value that determines whether the cell have a mark.
 */
@property (nonatomic, getter = isMarked) BOOL marked;

/**
 A Boolean value that determines whether all tasks for the cell's day are completed.
 */
@property (nonatomic, getter = isCompleted) BOOL completed;

///---------------------------------------
/// @name Accessing Attributes of the View
///---------------------------------------

/**
 The view’s background color. Default value is `[UIColor clearColor]`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)selfBackgroundColor;

///---------------------------------------
/// @name Accessing Attributes of Subviews
///---------------------------------------

/**
 The font of the text which displayed by the label of the day. Default value is [UIFont fontWithName:@"HelveticaNeue" size:18.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)dayLabelFont;

/**
 The text color for the label of the day. Default value is [UIColor blackColor].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)dayLabelTextColor;

/**
 The text color for the label of the day off. Default value is [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)dayOffLabelTextColor;

/**
 The font for the label of the current day. Default value is [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)todayLabelFont;

/**
 The text color for the label of the current day. Default value is [UIColor whiteColor].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)todayLabelTextColor;

/**
 The color of the background image for the cell of the current day. Default value is [UIColor colorWithRed:0/255.0f green:121/255.0f blue:255/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization. Ignored if `customTodayImage` is not equal to `nil`.
 */
- (UIColor *)todayImageColor;

/**
 The custom background image for the cell of the current day. Default value is `nil`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIImage *)customTodayImage;

/**
 The color of the overlay image for the cell of the day. Default value is [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization. Ignored if `customOverlayImage` is not equal to `nil`.
 */
- (UIColor *)overlayImageColor;

/**
 The custom overlay image for the cell of the current day. Default value is `nil`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIImage *)customOverlayImage;

/**
 The color of the incomplete mark image for the cell of the day. Default value is [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization. Ignored if `customIncompleteMarkImage` is not equal to `nil`.
 */
- (UIColor *)incompleteMarkImageColor;

/**
 The custom incomplete mark image for the cell of the day. Default value is `nil`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIImage *)customIncompleteMarkImage;

/**
 The color of the complete mark image for the cell of the day. Default value is [UIColor colorWithRed:83/255.0f green:215/255.0f blue:105/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization. Ignored if `customCompleteMarkImage` is not equal to `nil`.
 */
- (UIColor *)completeMarkImageColor;

/**
 The custom complete mark image for the cell of the day. Default value is `nil`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIImage *)customCompleteMarkImage;

/**
 The color of the divider image for the cell of the day. Default value is [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization. Ignored if `customDividerImage` is not equal to `nil`.
 */
- (UIColor *)dividerImageColor;

/**
 The custom divider image for the cell of the day. Default value is `nil`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIImage *)customDividerImage;

@end

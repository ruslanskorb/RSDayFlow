#import <UIKit/UIKit.h>
#import "RSDayFlow.h"

/**
 The `RSDFDatePickerMonthHeader` is a reusable view which used to display a month and year in the date picker view.
 */
@interface RSDFDatePickerMonthHeader : UICollectionReusableView

///-------------------------
/// @name Accessing Subviews
///-------------------------

/**
 The label showing the view's date.
 */
@property (nonatomic, readonly, strong) UILabel *dateLabel;

///----------------------------------------
/// @name Accessing Attributes of the Month
///----------------------------------------

/**
 A date which corresponds to the current view.
 */
@property (nonatomic, readwrite, assign) RSDFDatePickerDate date;

/**
 A Boolean value that determines whether the view represents the current month.
 */
@property (nonatomic, getter = isCurrentMonth) BOOL currentMonth;

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
 The font for the label of the month. Default value is [UIFont fontWithName:@"HelveticaNeue" size:16.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)monthLabelFont;

/**
 The text color for the label of the month. Default value is [UIColor blackColor].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)monthLabelTextColor;

/**
 The text color for the label of the current month. Default value is [UIColor colorWithRed:32/255.0f green:135/255.0f blue:252/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)currentMonthLabelTextColor;

@end

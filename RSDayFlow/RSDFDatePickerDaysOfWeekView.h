#import <UIKit/UIKit.h>

/**
 The `RSDFDatePickerDaysOfWeekView` is a view with labels for each day of the week.
 */
@interface RSDFDatePickerDaysOfWeekView : UIView

/**
 Designated initializer. Initializes and returns a newly allocated view object with the specified frame rectangle and the specified calendar.
 
 @param frame The frame rectangle for the view, measured in points.
 @param calendar The calendar for days of the week.
 */
- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar;

///---------------------------------------
/// @name Accessing Attributes of the View
///---------------------------------------

/**
 The view’s background color. Default value is `[UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0]`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)selfBackgroundColor;

///-----------------------------------------
/// @name Accessing Attributes of the Layout
///-----------------------------------------

/**
 The size to use for labels of weekdays. Default value is {44, 22}.
 
  @discussion Can be overridden in subclasses for customization.
 */
- (CGSize)selfItemSize;

/**
 The spacing to use between labels. Default value is `2.0f`.
 
  @discussion Can be overridden in subclasses for customization.
 */
- (CGFloat)selfInteritemSpacing;

///---------------------------------------
/// @name Accessing Attributes of Subviews
///---------------------------------------

/**
 The font for the label of the weekday. Default value is [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)dayOfWeekLabelFont;

/**
 The text color for the label of the weekday. Default value is [UIColor blackColor].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)dayOfWeekLabelTextColor;

/**
 The text color for the label of the day off of the week. Default value is [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0].å
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)dayOffOfWeekLabelTextColor;

@end

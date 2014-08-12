#import <UIKit/UIKit.h>
#import "RSDayFlow.h"

/**
 `RSDFDatePickerMonthHeader` is a reusable view which used to display a month and year in the date picker view.
 */
@interface RSDFDatePickerMonthHeader : UICollectionReusableView

///-------------------------
/// @name Accessing Subviews
///-------------------------

/**
 The label showing the view's date.
 */
@property (nonatomic, readonly, strong) UILabel *dateLabel;

///-------------------------------------
/// @name Accessing the Month Attributes
///-------------------------------------

/**
 A date which corresponds to the current view.
 */
@property (nonatomic, readwrite, assign) RSDFDatePickerDate date;

/**
 A Boolean value that determines whether the view represents the current month.
 */
@property (nonatomic, getter = isCurrentMonth) BOOL currentMonth;

@end

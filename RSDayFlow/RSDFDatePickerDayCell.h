#import <UIKit/UIKit.h>
#import "RSDayFlow.h"

/**
 `RSDFDatePickerDayCell` is a cell which used to display a day in the date picker view.
 */
@interface RSDFDatePickerDayCell : UICollectionViewCell

///-------------------------
/// @name Accessing Subviews
///-------------------------

/**
 The label showing the cell's date.
 */
@property (nonatomic, readonly, strong) UILabel *dateLabel;

///-----------------------------------
/// @name Accessing the Day Attributes
///-----------------------------------

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
 A Boolean value that determines whether the cell have a mark.
 */
@property (nonatomic, getter = isMarked) BOOL marked;

/**
 A Boolean value that determines whether all tasks for the cell's day are completed.
 */
@property (nonatomic, getter = isCompleted) BOOL completed;

/**
 A Boolean value that determines whether the cell represents the current day.
 */
@property (nonatomic, getter = isToday) BOOL today;

@end

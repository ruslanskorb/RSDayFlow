#import <UIKit/UIKit.h>

@protocol RSDFDatePickerViewDelegate;
@protocol RSDFDatePickerViewDataSource;

/**
 `RSDFDatePickerView` is a calendar view with infinity scrolling.
*/
@interface RSDFDatePickerView : UIView

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.
 
 @discussion A `RSDFDatePickerView` delegate responds to message sent by tapping on date in the date picker view.
 */
@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDelegate> delegate;

///--------------------------------
/// @name Accessing the Data Source
///--------------------------------

/**
 The receiver's data source.
 
 @discussion A `RSDFDatePickerView` data source provides dates to mark in the date picker view.
 */

@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDataSource> dataSource;

///-----------------------------------
/// @name Scrolling to the Current Day
///-----------------------------------

/**
 Scrolls the date picker view to the current day.
 
 @param animated YES if you want to animate the change in position, NO if it should be immediate.
 */

- (void)scrollToToday:(BOOL)animated;

///-------------------------
/// @name Reloading the Data
///-------------------------

/**
 Reloads all of the data for the date picker view.
 
 @discussion Discard the dataSource and delegate data and requery as necessary.
 */
- (void)reloadData;

@end

/**
 The `RSDFDatePickerViewDelegate` protocol defines the message sent to a date picker view delegate when date is tapped.
 */
@protocol RSDFDatePickerViewDelegate <NSObject>

///-----------------------------------
/// @name Responding to Date Selection
///-----------------------------------

@optional

/**
 Tells the delegate that the user did select a date.
 
 @param view The view whose date was selected.
 @param date The selected date.
 */
- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date;

@end

/**
 The `RSDFDatePickerViewDataSource` protocol is adopted by an object that provides dates to mark in the date picker view.
 */
@protocol RSDFDatePickerViewDataSource <NSObject>

///------------------------------
/// @name Providing Dates to Mark
///------------------------------

@optional

/**
 Provides dates to mark for the data source.
 
 @param view The view to whom dates are provided.
 
 @return The dictionary that contains dates (as keys) and completeness of tasks on these days (as objects).
 */
- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view;

@end

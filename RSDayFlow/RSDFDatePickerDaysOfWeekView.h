#import <UIKit/UIKit.h>

/**
 `RSDFDatePickerDaysOfWeekView` is a view with labels for each day of the week.
 */
@interface RSDFDatePickerDaysOfWeekView : UIView

/**
 Designated initializer. Initializes and returns a newly allocated view object with the specified frame rectangle and the specified calendar.
 
 @param frame The frame rectangle for the view, measured in points.
 @param calendar The calendar for days of the week.
 */
- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar;

@end

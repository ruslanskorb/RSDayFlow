#import <UIKit/UIKit.h>

@interface DFDatePickerView : UIView

- (instancetype) initWithCalendar:(NSCalendar *)calendar;

@property (nonatomic, readwrite, strong) NSDate *selectedDate;

@end

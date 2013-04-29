#import <UIKit/UIKit.h>
#import "DFDatePickerView.h"

@class DFDatePickerViewController;
@protocol DFDatePickerViewControllerDelegate

- (void) datePickerViewController:(DFDatePickerViewController *)controller didSelectDate:(NSDate *)date;

@end

@interface DFDatePickerViewController : UIViewController

@property (nonatomic, readonly, strong) DFDatePickerView *datePickerView;
@property (nonatomic, readwrite, weak) id<DFDatePickerViewControllerDelegate> delegate;

@end

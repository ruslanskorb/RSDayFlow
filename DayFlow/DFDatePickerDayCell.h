#import <UIKit/UIKit.h>
#import "DayFlow.h"

@interface DFDatePickerDayCell : UICollectionViewCell

@property (nonatomic, readwrite, assign) DFDatePickerDate date;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

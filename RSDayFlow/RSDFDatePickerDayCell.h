#import <UIKit/UIKit.h>
#import "RSDayFlow.h"

@interface RSDFDatePickerDayCell : UICollectionViewCell

@property (nonatomic, readwrite, assign)    RSDFDatePickerDate date;
@property (nonatomic, readonly, strong)     UILabel *dateLabel;

@property (nonatomic, getter = isEnabled)   BOOL enabled;
@property (nonatomic, getter = isDayOff)    BOOL dayOff;
@property (nonatomic, getter = isMarked)    BOOL marked;
@property (nonatomic, getter = isCompleted) BOOL completed;
@property (nonatomic, getter = isToday)     BOOL today;

@end

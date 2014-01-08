#import <UIKit/UIKit.h>

@protocol RSDFDatePickerViewDelegate;
@protocol RSDFDatePickerViewDataSource;

@interface RSDFDatePickerView : UIView

@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDelegate> delegate;
@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDataSource> dataSource;

- (void)reloadData;

@end

@protocol RSDFDatePickerViewDelegate

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date;

@end

@protocol RSDFDatePickerViewDataSource

@optional
- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view;

@end

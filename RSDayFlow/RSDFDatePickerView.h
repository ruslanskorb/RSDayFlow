#import <UIKit/UIKit.h>

@protocol RSDFDatePickerViewDelegate;
@protocol RSDFDatePickerViewDataSource;

@interface RSDFDatePickerView : UIView

@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDelegate> delegate;
@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDataSource> dataSource;

- (void)scrollToToday:(BOOL)animated;
- (void)reloadData;

@end

@protocol RSDFDatePickerViewDelegate <NSObject>

@optional

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date;

@end

@protocol RSDFDatePickerViewDataSource <NSObject>

@optional

- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view;

@end

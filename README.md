# RSDayFlow

<p align="center">
	<img src="Screenshot.png" alt="Sample">
</p>

iOS 7 Calendar with Infinite Scrolling. Only need 4 lines of code to set up.

> [RSDayFlow](https://github.com/ruslanskorb/RSDayFlow) is a slim fork of [DayFlow](https://github.com/evadne/DayFlow) with updates and extensions:

> * Possibility to mark the date
* 2 colors of marks that can be used in the Task Manager (gray color - days with uncompleted tasks, green color - days with completed tasks)
* Design like iOS 7
* Some other updates

## Installation

[CocoaPods](http://cocoapods.org) is the recommended method of installing RSDayFlow. Simply add the following line to your `Podfile`:

#### Podfile

```ruby
pod 'RSDayFlow'
```

## Basic Usage

Import the class header.

``` objective-c
#import "RSDFDatePickerView.h"
```

Just create your date picker view and set a delegate / a data source if needed.

``` objective-c
- (void) viewDidLoad
{
	[super viewDidLoad];
	
	RSDFDatePickerView *datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds];
	datePickerView.delegate = self;
    datePickerView.dataSource = self;
    [self.view addSubview:datePickerView];
}
```

## Delegate (optional)

`RSDFDatePickerView` provides one delegate method `didSelectDate`. It gets called when a user click on a specific date. To use it, implement the delegate in your view controller.

```objective-c
@interface ViewController () <RSDFDatePickerViewDelegate>
```

Then implement the delegate function.

```objective-c
// Prints out the selected date.
- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
	NSLog(@"%@", [date description]);
}
```

## DataSource (optional)

`RSDFDatePickerView` provides one data source method `datePickerViewMarkedDates`. It uses to mark dates by using markers of different colors like iOS 7 Calendar app. To use it, implement the data source in your view controller.

```objective-c
@interface ViewController () <RSDFDatePickerViewDataSource>
```

Then implement the data source function.

```objective-c
// Returns dates to mark.
- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view
{
	NSDate *today = [NSDate date];
    NSNumber *isCompletedAllTasks = @(NO);
    NSDictionary *dates = @{today: isCompletedAllTasks};
    return markedDates;
}
```

## Coming Soon

- Make the code more documented
- Make every view maximum customizable

- If you would like to request a new feature, feel free to raise as an issue.

## Demo

Look at the [Sample App](https://github.com/ruslanskorb/RSDayFlow-Sample). Have fun. Make it faster. Fork and send pull requests. Figure out hooks for customization.


## Contact

Ruslan Skorb

- http://github.com/ruslanskorb
- http://twitter.com/ruslanskorb
- http://lnkd.in/gsBbvb
- ruslan.skorb@gmail.com

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/ruslanskorb/RSDayFlow) is appreciated.

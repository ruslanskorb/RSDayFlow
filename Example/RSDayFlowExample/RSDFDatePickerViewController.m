//
// RSDFDatePickerViewController.m
//
// Copyright (c) 2013 Evadne Wu, http://radi.ws/
// Copyright (c) 2013-2014 Ruslan Skorb, http://lnkd.in/gsBbvb
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RSDFDatePickerViewController.h"
#import "RSDFDatePickerView.h"

@interface RSDFDatePickerViewController() <RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>

@end

@implementation RSDFDatePickerViewController

@synthesize datePickerView = _datePickerView;

#pragma mark - Lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"RSDayFlow";

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f]};
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    UIBarButtonItem *today = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(onTodayButtonTouch:)];
    self.navigationItem.rightBarButtonItem = today;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [self.view addSubview:self.datePickerView];
}

#pragma mark - Custom Accessors

- (RSDFDatePickerView *)datePickerView
{
	if (!_datePickerView) {
		_datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
		_datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return _datePickerView;
}

#pragma mark - Action handling

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
    [self.datePickerView scrollToToday:YES];
}

#pragma mark - RSDFDatePickerViewDelegate

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    [[[UIAlertView alloc] initWithTitle:@"Picked Date" message:[date description] delegate:nil cancelButtonTitle:@":D" otherButtonTitles:nil] show];
}

#pragma mark - RSDFDatePickerViewDataSource

- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:todayComponents];
    
    NSArray *numberOfDaysFromToday = @[@(-8), @(-2), @(-1), @(0), @(2), @(4), @(8), @(13), @(22)];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSMutableDictionary *markedDates = [[NSMutableDictionary alloc] initWithCapacity:[numberOfDaysFromToday count]];
    [numberOfDaysFromToday enumerateObjectsUsingBlock:^(NSNumber *numberOfDays, NSUInteger idx, BOOL *stop) {
        dateComponents.day = [numberOfDays integerValue];
        NSDate *date = [calendar dateByAddingComponents:dateComponents toDate:today options:0];
        if ([date compare:today] == NSOrderedAscending) {
            markedDates[date] = @YES;
        } else {
            markedDates[date] = @NO;
        }
    }];
    
    return [markedDates copy];
}

@end

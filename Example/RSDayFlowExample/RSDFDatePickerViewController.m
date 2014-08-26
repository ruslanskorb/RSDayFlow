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
#import "RSDFCustomDatePickerView.h"

@interface RSDFDatePickerViewController() <RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>

@property (strong, nonatomic) NSDictionary *markedDates;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) RSDFDatePickerView *datePickerView;
@property (strong, nonatomic) RSDFCustomDatePickerView *customDatePickerView;

@end

@implementation RSDFDatePickerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f]};
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    UIBarButtonItem *today = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(onTodayButtonTouch:)];
    self.navigationItem.rightBarButtonItem = today;
    
    UIBarButtonItem *restyle = [[UIBarButtonItem alloc] initWithTitle:@"Restyle" style:UIBarButtonItemStyleBordered target:self action:@selector(onRestyleButtonTouch:)];
    self.navigationItem.leftBarButtonItem = restyle;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [self.view addSubview:self.datePickerView];
}

#pragma mark - Custom Accessors

- (void)setCalendar:(NSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        
        self.title = [_calendar.calendarIdentifier capitalizedString];
    }
}

- (NSDictionary *)markedDates
{
    if (!_markedDates) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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
        
        _markedDates = [markedDates copy];
    }
    return _markedDates;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setCalendar:self.calendar];
        [_dateFormatter setLocale:[self.calendar locale]];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    return _dateFormatter;
}

- (RSDFDatePickerView *)datePickerView
{
	if (!_datePickerView) {
		_datePickerView = [[RSDFDatePickerView alloc] initWithFrame:self.view.bounds calendar:self.calendar];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
		_datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return _datePickerView;
}

- (RSDFCustomDatePickerView *)customDatePickerView
{
    if (!_customDatePickerView) {
        _customDatePickerView = [[RSDFCustomDatePickerView alloc] initWithFrame:self.view.bounds calendar:self.calendar];
        _customDatePickerView.delegate = self;
        _customDatePickerView.dataSource = self;
		_customDatePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _customDatePickerView;
}

#pragma mark - Action handling

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
    if (self.datePickerView.superview) {
        [self.datePickerView scrollToToday:YES];
    } else {
        [self.customDatePickerView scrollToToday:YES];
    }
}

- (void)onRestyleButtonTouch:(UIBarButtonItem *)sender
{
    if (self.datePickerView.superview) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244/255.0f green:245/255.0f blue:247/255.0f alpha:1.0f];
        [self.datePickerView removeFromSuperview];
        [self.view addSubview:self.customDatePickerView];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1.0f];
        [self.customDatePickerView removeFromSuperview];
        [self.view addSubview:self.datePickerView];
    }
}

#pragma mark - RSDFDatePickerViewDelegate

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    [[[UIAlertView alloc] initWithTitle:@"Picked Date" message:[self.dateFormatter stringFromDate:date] delegate:nil cancelButtonTitle:@":D" otherButtonTitles:nil] show];
}

#pragma mark - RSDFDatePickerViewDataSource

- (NSDictionary *)datePickerViewMarkedDates:(RSDFDatePickerView *)view
{
	return self.markedDates;
}

@end

//
// RSDFDatePickerViewController.m
//
// Copyright (c) 2013 Evadne Wu, http://radi.ws/
// Copyright (c) 2013-2015 Ruslan Skorb, http://ruslanskorb.com
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

@property (copy, nonatomic) NSArray *datesToMark;
@property (copy, nonatomic) NSDictionary *statesOfTasks;
@property (copy, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) RSDFDatePickerView *datePickerView;
@property (strong, nonatomic) RSDFCustomDatePickerView *customDatePickerView;
@property (copy, nonatomic) UIColor *completedTasksColor;
@property (copy, nonatomic) UIColor *uncompletedTasksColor;
@property (copy, nonatomic) NSDate *today;

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
    
    UIBarButtonItem *todayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(onTodayButtonTouch:)];
    self.navigationItem.rightBarButtonItem = todayBarButtonItem;
    
    UIBarButtonItem *restyleBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restyle" style:UIBarButtonItemStylePlain target:self action:@selector(onRestyleButtonTouch:)];
    self.navigationItem.leftBarButtonItem = restyleBarButtonItem;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    
    NSDateComponents *todayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [self.calendar dateFromComponents:todayComponents];
    [self.datePickerView selectDate:today];
    
    self.customDatePickerView.hidden = YES;
    
    [self.view addSubview:self.customDatePickerView];
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

- (NSArray *)datesToMark
{
    if (!_datesToMark) {
        NSArray *numberOfDaysFromToday = @[@(-8), @(-2), @(-1), @(0), @(2), @(4), @(8), @(13), @(22)];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        NSMutableArray *datesToMark = [[NSMutableArray alloc] initWithCapacity:[numberOfDaysFromToday count]];
        [numberOfDaysFromToday enumerateObjectsUsingBlock:^(NSNumber *numberOfDays, NSUInteger idx, BOOL *stop) {
            dateComponents.day = [numberOfDays integerValue];
            NSDate *date = [self.calendar dateByAddingComponents:dateComponents toDate:self.today options:0];
            [datesToMark addObject:date];
        }];
        
        _datesToMark = [datesToMark copy];
    }
    return _datesToMark;
}

- (NSDictionary *)statesOfTasks
{
    if (!_statesOfTasks) {
        NSMutableDictionary *statesOfTasks = [[NSMutableDictionary alloc] initWithCapacity:[self.datesToMark count]];
        [self.datesToMark enumerateObjectsUsingBlock:^(NSDate *date, NSUInteger idx, BOOL *stop) {
            BOOL isCompletedAllTasks = NO;
            if ([date compare:self.today] == NSOrderedAscending) {
                isCompletedAllTasks = YES;
            }
            statesOfTasks[date] = @(isCompletedAllTasks);
        }];
        
        _statesOfTasks = [statesOfTasks copy];
    }
    return _statesOfTasks;
}

- (NSDate *)today
{
    if (!_today) {
        NSDateComponents *todayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        _today = [self.calendar dateFromComponents:todayComponents];
    }
    return _today;
}

- (UIColor *)completedTasksColor
{
    if (!_completedTasksColor) {
        _completedTasksColor = [UIColor colorWithRed:83/255.0f green:215/255.0f blue:105/255.0f alpha:1.0f];
    }
    return _completedTasksColor;
}

- (UIColor *)uncompletedTasksColor
{
    if (!_uncompletedTasksColor) {
        _uncompletedTasksColor = [UIColor colorWithRed:184/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
    }
    return _uncompletedTasksColor;
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
        _customDatePickerView.pagingEnabled = YES;
    }
    return _customDatePickerView;
}

#pragma mark - Action handling

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
    if (!self.datePickerView.hidden) {
        [self.datePickerView scrollToToday:YES];
    } else {
        [self.customDatePickerView scrollToToday:YES];
    }
}

- (void)onRestyleButtonTouch:(UIBarButtonItem *)sender
{
    if (!self.datePickerView.hidden) {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244/255.0f green:245/255.0f blue:247/255.0f alpha:1.0f];
        self.datePickerView.hidden = YES;
        self.customDatePickerView.hidden = NO;
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1.0f];
        self.customDatePickerView.hidden = YES;
        self.datePickerView.hidden = NO;
    }
}

#pragma mark - RSDFDatePickerViewDelegate

- (void)datePickerView:(RSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
    [[[UIAlertView alloc] initWithTitle:@"Picked Date" message:[self.dateFormatter stringFromDate:date] delegate:nil cancelButtonTitle:@":D" otherButtonTitles:nil] show];
}

#pragma mark - RSDFDatePickerViewDataSource

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldHighlightDate:(NSDate *)date
{
    if (view == self.datePickerView) {
        return YES;
    }
    
    if ([self.today compare:date] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldSelectDate:(NSDate *)date
{
    if (view == self.datePickerView) {
        return YES;
    }
    
    if ([self.today compare:date] == NSOrderedDescending) {
        return NO;
    }
    
    return YES;
}

- (BOOL)datePickerView:(RSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
    return [self.datesToMark containsObject:date];
}

- (UIColor *)datePickerView:(RSDFDatePickerView *)view markImageColorForDate:(NSDate *)date
{
    if (![self.statesOfTasks[date] boolValue]) {
        return self.uncompletedTasksColor;
    } else {
        return self.completedTasksColor;
    }
}

@end

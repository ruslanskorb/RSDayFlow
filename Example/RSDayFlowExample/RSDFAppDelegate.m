//
// RSDFAppDelegate.m
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

#import "RSDFAppDelegate.h"
#import "RSDFDatePickerViewController.h"

@implementation RSDFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // ------------------
    // Gregorian calendar
    // ------------------
    
    RSDFDatePickerViewController *gregorianVC = [[RSDFDatePickerViewController alloc] init];
    gregorianVC.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorianVC.calendar.locale = [NSLocale currentLocale];
    UINavigationController *gregorianNC = [[UINavigationController alloc] initWithRootViewController:gregorianVC];
    
    // ---------------
    // Hebrew calendar
    // ---------------
    
    RSDFDatePickerViewController *hebrewVC = [[RSDFDatePickerViewController alloc] init];
    hebrewVC.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierHebrew];
    hebrewVC.calendar.locale = [NSLocale currentLocale];
    UINavigationController *hebrewNC = [[UINavigationController alloc] initWithRootViewController:hebrewVC];
    
    // ----------------
    // Islamic calendar
    // ----------------
    
    RSDFDatePickerViewController *islamicVC = [[RSDFDatePickerViewController alloc] init];
    islamicVC.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierIslamic];
    islamicVC.calendar.locale = [NSLocale currentLocale];
    UINavigationController *islamicNC = [[UINavigationController alloc] initWithRootViewController:islamicVC];
    
    // ---------------
    // Indian calendar
    // ---------------
    
    RSDFDatePickerViewController *indianVC = [[RSDFDatePickerViewController alloc] init];
    indianVC.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierIndian];
    indianVC.calendar.locale = [NSLocale currentLocale];
    UINavigationController *indianNC = [[UINavigationController alloc] initWithRootViewController:indianVC];
    
    // ----------------
    // Persian calendar
    // ----------------
    
    RSDFDatePickerViewController *persianVC = [[RSDFDatePickerViewController alloc] init];
    persianVC.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierPersian];
    persianVC.calendar.locale = [NSLocale currentLocale];
    UINavigationController *persianNC = [[UINavigationController alloc] initWithRootViewController:persianVC];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[gregorianNC, hebrewNC, islamicNC, indianNC, persianNC];
	self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

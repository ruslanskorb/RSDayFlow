//
// RSDFDatePickerDaysOfWeekView.h
//
// Copyright (c) 2013 Evadne Wu, http://radi.ws/
// Copyright (c) 2013-2016 Ruslan Skorb, http://ruslanskorb.com
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, RSDFDaysOfWeekDisplayStyle) {
    /// Short Display style: M T W T F S S
    RSDFDaysOfWeekDisplayStyleShort,
    /// Medium Display Style: Mon Tue Wed Thu Fri Sat Sun
    RSDFDaysOfWeekDisplayStyleMedium,
    /// Long Display Style: Monday Tuesday Wednesday Thursday Friday Saturday Sunday
    RSDFDaysOfWeekDisplayStyleLong,
    /// Automatically determines which Style to use (based on view's frame)
    RSDFDaysOfWeekDisplayStyleAuto
};

/**
 The `RSDFDatePickerDaysOfWeekView` is a view with labels for each day of the week.
 */
@interface RSDFDatePickerDaysOfWeekView : UIView

/**
 Designated initializer. Initializes and returns a newly allocated view object with the specified frame rectangle and the specified calendar.
 
 @param frame The frame rectangle for the view, measured in points.
 @param calendar The calendar for days of the week.
 */
- (instancetype)initWithFrame:(CGRect)frame calendar:(nullable NSCalendar *)calendar;

///---------------------------------------
/// @name Accessing Attributes of the View
///---------------------------------------

/**
 The view’s background color. Default value is `[UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0]`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)selfBackgroundColor;

///-----------------------------------------
/// @name Accessing Attributes of the Layout
///-----------------------------------------

/**
 The size to use for labels of weekdays. Default size is calculated based on the size of the view.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (CGSize)selfItemSize;

/**
 The insets to use for labels of weekday. Default value is `UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)`.
 
 @discussion Can be overriden in sublclasses for customization.
 */
- (UIEdgeInsets)selfItemInsets;

/**
 The spacing to use between labels. Default value is `2.0f`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (CGFloat)selfInteritemSpacing;

///--------------------
/// @name Display Style
///--------------------

/**
 The Display Style to use. Default value is `RSDFDaysOfWeekDisplayStyleAuto`.
 
 @discussion Can be overriden in subclasses for customization.
 */
- (RSDFDaysOfWeekDisplayStyle)displayStyle;

///---------------------------------------
/// @name Accessing Attributes of Subviews
///---------------------------------------

/**
 The font for the label of the weekday. Default value depends on the interface idiom and the interface orientation.
 
 `UIUserInterfaceIdiomPhone`:
    - `UIInterfaceOrientationPortrait` or `UIInterfaceOrientationPortraitUpsideDown`: `[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0]`
    - Other: `[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]`
 Other:
    - Any: `[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]`
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)dayOfWeekLabelFont;

/**
 The font for the label of the day off of the week. Default value depends on the interface idiom and the interface orientation.

 `UIUserInterfaceIdiomPhone`:
    - `UIInterfaceOrientationPortrait` or `UIInterfaceOrientationPortraitUpsideDown`: `[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0]`
    - Other: `[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]`
 Other:
    - Any: `[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]`

 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)dayOffOfWeekLabelFont;

/**
 The text color for the label of the weekday. Default value is [UIColor blackColor].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)dayOfWeekLabelTextColor;

/**
 The text color for the label of the day off of the week. Default value is [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)dayOffOfWeekLabelTextColor;

@end

NS_ASSUME_NONNULL_END

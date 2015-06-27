//
// RSDFDatePickerMonthHeader.h
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

#import <UIKit/UIKit.h>
#import "RSDFDatePickerDate.h"

/**
 The `RSDFDatePickerMonthHeader` is a reusable view which used to display a month and year in the date picker view.
 */
@interface RSDFDatePickerMonthHeader : UICollectionReusableView

///-------------------------
/// @name Accessing Subviews
///-------------------------

/**
 The label showing the view's date.
 */
@property (nonatomic, readonly, strong) UILabel *dateLabel;

///----------------------------------------
/// @name Accessing Attributes of the Month
///----------------------------------------

/**
 A date which corresponds to the current view.
 */
@property (nonatomic, readwrite, assign) RSDFDatePickerDate date;

/**
 A Boolean value that determines whether the view represents the current month.
 */
@property (nonatomic, getter = isCurrentMonth) BOOL currentMonth;

///---------------------------------------
/// @name Accessing Attributes of the View
///---------------------------------------

/**
 The view’s background color. Default value is `[UIColor clearColor]`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)selfBackgroundColor;

///---------------------------------------
/// @name Accessing Attributes of Subviews
///---------------------------------------

/**
 The font for the label of the month. Default value is [UIFont fontWithName:@"HelveticaNeue" size:16.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIFont *)monthLabelFont;

/**
 The text color for the label of the month. Default value is [UIColor blackColor].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)monthLabelTextColor;

/**
 The text color for the label of the current month. Default value is [UIColor colorWithRed:32/255.0f green:135/255.0f blue:252/255.0f alpha:1.0f].
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)currentMonthLabelTextColor;

@end

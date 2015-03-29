//
// RSDFCustomDatePickerDayCell.m
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

#import "RSDFCustomDatePickerDayCell.h"

@implementation RSDFCustomDatePickerDayCell

- (UIFont *)dayLabelFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
}

- (UIColor *)dayLabelTextColor
{
    return [UIColor colorWithRed:51/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f];
}

- (UIColor *)selectedDayImageColor
{
    return [UIColor clearColor];
}

- (UIFont *)selectedDayLabelFont
{
    return [self dayLabelFont];
}

- (UIColor *)selectedDayLabelTextColor
{
    return [self dayLabelTextColor];
}

- (UIColor *)dayOffLabelTextColor
{
    return [UIColor colorWithRed:51/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f];
}

- (UIFont *)todayLabelFont
{
    return [UIFont fontWithName:@"AvenirNext-Bold" size:17.0f];
}

- (UIColor *)todayLabelTextColor
{
    return [UIColor colorWithRed:3/255.0f green:117/255.0f blue:214/255.0f alpha:1.0f];
}

- (UIColor *)selectedTodayImageColor
{
    return [UIColor clearColor];
}

- (UIFont *)selectedTodayLabelFont
{
    return [self todayLabelFont];
}

- (UIColor *)selectedTodayLabelTextColor
{
    return [self todayLabelTextColor];
}

- (UIColor *)overlayImageColor
{
    return [UIColor colorWithWhite:1.0f alpha:1.0f];
}

- (UIColor *)dividerImageColor
{
    return [UIColor clearColor];
}

-(UIImage *)customCompleteMarkImage{
    
    CGRect frame = CGRectMake(0, 0, 35.0f, 35.0f);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, self.window.screen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillEllipseInRect(context, frame);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeEllipseInRect(context, CGRectInset(frame, 1, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

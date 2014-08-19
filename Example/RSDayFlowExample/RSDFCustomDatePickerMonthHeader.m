//
// RSDFCustomDatePickerMonthHeader.m
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

#import "RSDFCustomDatePickerMonthHeader.h"

@implementation RSDFCustomDatePickerMonthHeader

- (UIColor *)selfBackgroundColor
{
    return [UIColor colorWithRed:244/255.0f green:245/255.0f blue:247/255.0f alpha:1.0f];
}

- (UIFont *)monthLabelFont
{
    return [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
}

- (UIColor *)monthLabelTextColor
{
    return [UIColor colorWithRed:51/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f];
}

- (UIColor *)currentMonthLabelTextColor
{
    return [UIColor colorWithRed:3/255.0f green:117/255.0f blue:214/255.0f alpha:1.0f];
}

@end

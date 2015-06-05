//
// RSDFDatePickerMonthHeader.m
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

#import "RSDFDatePickerMonthHeader.h"

@implementation RSDFDatePickerMonthHeader

@synthesize dateLabel = _dateLabel;

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInitializer];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (void)commonInitializer
{
    self.backgroundColor = [self selfBackgroundColor];
}

#pragma mark - Custom Accessors

- (UILabel *)dateLabel
{
	if (!_dateLabel) {
		_dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.opaque = NO;
		_dateLabel.textAlignment = NSTextAlignmentCenter;
		_dateLabel.font = [self monthLabelFont];
		_dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_dateLabel];
	}
	return _dateLabel;
}

- (void)setDate:(RSDFDatePickerDate)date
{
    _date = date;
}

- (void)setCurrentMonth:(BOOL)currentMonth
{
    _currentMonth = currentMonth;
    if (!_currentMonth) {
        self.dateLabel.textColor = [self monthLabelTextColor];
    } else {
        self.dateLabel.textColor = [self currentMonthLabelTextColor];
    }
}

#pragma mark - Attributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor clearColor];
}

#pragma mark - Attributes of Subviews

- (UIFont *)monthLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
}

- (UIColor *)monthLabelTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)currentMonthLabelTextColor
{
    return [UIColor colorWithRed:32/255.0f green:135/255.0f blue:252/255.0f alpha:1.0f];
}

@end

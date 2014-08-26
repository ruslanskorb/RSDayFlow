//
// RSDFDatePickerDaysOfWeekView.m
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

#import "RSDFDatePickerDaysOfWeekView.h"
#import "NSCalendar+RSDFAdditions.h"

@interface RSDFDatePickerDaysOfWeekView ()

@property (strong, nonatomic) NSCalendar *calendar;

@end

@implementation RSDFDatePickerDaysOfWeekView

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

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:frame];
    if (self) {
        _calendar = calendar;
        [self commonInitializer];
    }
    return self;
}

#pragma mark - Custom Accessors

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _calendar.locale = [NSLocale currentLocale];
    }
    return _calendar;
}

#pragma mark - Private

- (void)commonInitializer
{
    self.backgroundColor = [self selfBackgroundColor];
    
    UIColor *dayOfWeekLabelBackgroundColor = [UIColor clearColor];
    UIFont *dayOfWeekLabelFont = [self dayOfWeekLabelFont];
    UIColor *dayOfWeekLabelTextColor = [self dayOfWeekLabelTextColor];
    UIColor *dayOffOfWeekLabelTextColor = [self dayOffOfWeekLabelTextColor];
    
    //	Hard key these things.
    //	44 * 7 + 2 * 6 = 320; in accordance with RSDFDatePickerCollectionViewLayout
    
    CGSize itemSize = [self selfItemSize];
    CGFloat interitemSpacing = [self selfInteritemSpacing];
    
    CGFloat y = 0;
    __block CGFloat x = 0;
    
    NSString *dateFormatterName = [NSString stringWithFormat:@"calendarDaysOfWeekView_%@_%@", [self.calendar calendarIdentifier], [[self.calendar locale] localeIdentifier]];
    NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:dateFormatterName withConstructor:^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:self.calendar];
        [dateFormatter setLocale:[self.calendar locale]];
        return dateFormatter;
    }];
    
    NSArray *weekdaySymbols = [dateFormatter veryShortStandaloneWeekdaySymbols];
    NSArray *reorderedWeekdaySymbols = nil;
    
    // weekday start from 1
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        reorderedWeekdaySymbols = [[weekdaySymbols subarrayWithRange:NSMakeRange(firstWeekdayIndex, [weekdaySymbols count] - firstWeekdayIndex)]
                                   arrayByAddingObjectsFromArray:[weekdaySymbols subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    } else {
        reorderedWeekdaySymbols = weekdaySymbols;
    }
    
    [reorderedWeekdaySymbols enumerateObjectsUsingBlock:^(NSString *weekdaySymbol, NSUInteger idx, BOOL *stop) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, itemSize.width, itemSize.height)];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.backgroundColor = dayOfWeekLabelBackgroundColor;
        weekdayLabel.font = dayOfWeekLabelFont;
        if ([weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 0 && [weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 6) {
            weekdayLabel.textColor = dayOfWeekLabelTextColor;
        } else {
            weekdayLabel.textColor = dayOffOfWeekLabelTextColor;
        }
        weekdayLabel.text = weekdaySymbol;
        [self addSubview:weekdayLabel];
        
        x += (itemSize.width + interitemSpacing);
    }];
}

#pragma mark - Attributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0];
}

#pragma mark - Attributes of the Layout

- (CGSize)selfItemSize
{
    return (CGSize){ 44, 22 };
}

- (CGFloat)selfInteritemSpacing
{
    return 2.0f;
}

#pragma mark - Attributes of Subviews

- (UIFont *)dayOfWeekLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
}

- (UIColor *)dayOfWeekLabelTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)dayOffOfWeekLabelTextColor
{
    return [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
}

@end

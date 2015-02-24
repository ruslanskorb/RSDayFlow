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
@property (strong, nonatomic) NSArray *weekdayLabels;
@property (strong, nonatomic) NSArray *veryShortStandaloneWeekdaySymbols;
@property (strong, nonatomic) NSArray *shortStandaloneWeekdaySymbols;
@property (strong, nonatomic) NSArray *standaloneWeekdaySymbols;

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutWeekdayLabels];
    [self updateWeekdayLabels];
}

#pragma mark - Custom Accessors

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
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
    
    NSString *dateFormatterName = [NSString stringWithFormat:@"calendarDaysOfWeekView_%@_%@", [self.calendar calendarIdentifier], [[self.calendar locale] localeIdentifier]];
    NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:dateFormatterName withConstructor:^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:self.calendar];
        [dateFormatter setLocale:[self.calendar locale]];
        return dateFormatter;
    }];
    
    BOOL isPhone = [self isPhone];
    BOOL isPortraitInterfaceOrientation = [self isPortraitInterfaceOrientation];
    
    NSArray *weekdaySymbols = nil;
    if (isPhone) {
        self.veryShortStandaloneWeekdaySymbols = [dateFormatter veryShortStandaloneWeekdaySymbols];
        self.shortStandaloneWeekdaySymbols = [dateFormatter shortStandaloneWeekdaySymbols];
        
        if (isPortraitInterfaceOrientation) {
            weekdaySymbols = self.veryShortStandaloneWeekdaySymbols;
        } else {
            weekdaySymbols = self.shortStandaloneWeekdaySymbols;
        }
    } else {
        self.shortStandaloneWeekdaySymbols = [dateFormatter shortStandaloneWeekdaySymbols];
        self.standaloneWeekdaySymbols = [dateFormatter standaloneWeekdaySymbols];
        
        if (isPortraitInterfaceOrientation) {
            weekdaySymbols = self.shortStandaloneWeekdaySymbols;
        } else {
            weekdaySymbols = self.standaloneWeekdaySymbols;
        }
    }
    
    NSArray *reorderedWeekdaySymbols = nil;
    
    // weekday start from 1
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        if (isPhone) {
            self.veryShortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.veryShortStandaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
            self.shortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.shortStandaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
            
            if (isPortraitInterfaceOrientation) {
                reorderedWeekdaySymbols = self.veryShortStandaloneWeekdaySymbols;
            } else {
                reorderedWeekdaySymbols = self.shortStandaloneWeekdaySymbols;
            }
        } else {
            self.shortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.shortStandaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
            self.standaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.standaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
            
            if (isPortraitInterfaceOrientation) {
                reorderedWeekdaySymbols = self.shortStandaloneWeekdaySymbols;
            } else {
                reorderedWeekdaySymbols = self.standaloneWeekdaySymbols;
            }
        }
    } else {
        reorderedWeekdaySymbols = weekdaySymbols;
    }
    
    NSMutableArray *weekdayLabels = [NSMutableArray arrayWithCapacity:[reorderedWeekdaySymbols count]];
    [reorderedWeekdaySymbols enumerateObjectsUsingBlock:^(NSString *weekdaySymbol, NSUInteger idx, BOOL *stop) {
        UILabel *weekdayLabel = [[UILabel alloc] init];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.backgroundColor = dayOfWeekLabelBackgroundColor;
        weekdayLabel.font = dayOfWeekLabelFont;
        if ([weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 0 && [weekdaySymbols indexOfObjectIdenticalTo:weekdaySymbol] != 6) {
            weekdayLabel.textColor = dayOfWeekLabelTextColor;
        } else {
            weekdayLabel.textColor = dayOffOfWeekLabelTextColor;
        }
        weekdayLabel.text = weekdaySymbol;
        [weekdayLabels addObject:weekdayLabel];
        [self addSubview:weekdayLabel];
    }];
    
    self.weekdayLabels = [weekdayLabels copy];
}

- (NSArray *)reorderedWeekdaySymbols:(NSArray *)weekdaySymbols firstWeekdayIndex:(NSUInteger)firstWeekdayIndex
{
    return [[weekdaySymbols subarrayWithRange:NSMakeRange(firstWeekdayIndex, [weekdaySymbols count] - firstWeekdayIndex)]
            arrayByAddingObjectsFromArray:[weekdaySymbols subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
}

- (void)layoutWeekdayLabels
{
    CGSize itemSize = [self selfItemSize];
    CGFloat interitemSpacing = [self selfInteritemSpacing];
    
    CGFloat y = 0;
    __block CGFloat x;
    
    NSLocaleLanguageDirection characterDirection = [NSLocale characterDirectionForLanguage:self.calendar.locale.localeIdentifier];
    if (characterDirection == NSLocaleLanguageDirectionRightToLeft) {
        x = CGRectGetWidth(self.frame) - itemSize.width;
        [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
            CGRect weekdayLabelFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
            weekdayLabel.frame = weekdayLabelFrame;
            x -= (itemSize.width + interitemSpacing);
        }];
    } else {
        x = 0;
        [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
            CGRect weekdayLabelFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
            weekdayLabel.frame = weekdayLabelFrame;
            x += (itemSize.width + interitemSpacing);
        }];
    }
}

- (void)updateWeekdayLabels
{
    BOOL isPhone = [self isPhone];
    BOOL isPortraitInterfaceOrientation = [self isPortraitInterfaceOrientation];
    
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
        weekdayLabel.font = [self dayOfWeekLabelFont];
        if (isPhone) {
            if (isPortraitInterfaceOrientation) {
                weekdayLabel.text = self.veryShortStandaloneWeekdaySymbols[idx];
            } else {
                weekdayLabel.text = self.shortStandaloneWeekdaySymbols[idx];
            }
        } else {
            if (isPortraitInterfaceOrientation) {
                weekdayLabel.text = self.shortStandaloneWeekdaySymbols[idx];
            } else {
                weekdayLabel.text = self.standaloneWeekdaySymbols[idx];
            }
        }
    }];
}

- (BOOL)isPhone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

- (BOOL)isPortraitInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

#pragma mark - Attributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0];
}

#pragma mark - Attributes of the Layout

- (CGSize)selfItemSize
{
    NSUInteger numberOfItems = 7;
    CGFloat totalInteritemSpacing = [self selfInteritemSpacing] * (numberOfItems - 1);
    
    CGFloat selfItemWidth = (CGRectGetWidth(self.frame) - totalInteritemSpacing) / numberOfItems;
    selfItemWidth = floor(selfItemWidth * 1000) / 1000;
    CGFloat selfItemHeight = CGRectGetHeight(self.frame);
    
    return (CGSize){ selfItemWidth, selfItemHeight };
}

- (CGFloat)selfInteritemSpacing
{
    return 2.0f;
}

#pragma mark - Attributes of Subviews

- (UIFont *)dayOfWeekLabelFont
{
    if ([self isPhone]) {
        if ([self isPortraitInterfaceOrientation]) {
            return [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        } else {
            return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        }
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    }
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

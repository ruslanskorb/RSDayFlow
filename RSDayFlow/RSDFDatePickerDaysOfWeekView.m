//
// RSDFDatePickerDaysOfWeekView.m
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

#import "RSDFDatePickerDaysOfWeekView.h"
#import "NSCalendar+RSDFAdditions.h"

@interface RSDFDatePickerDaysOfWeekView ()

@property (copy, nonatomic) NSCalendar *calendar;
@property (copy, nonatomic) NSArray *weekdayLabels;
@property (copy, nonatomic) NSArray *veryShortStandaloneWeekdaySymbols;
@property (copy, nonatomic) NSArray *shortStandaloneWeekdaySymbols;
@property (copy, nonatomic) NSArray *standaloneWeekdaySymbols;
@property (copy, nonatomic) NSArray *lastSymbolsUsed;
@property (assign, nonatomic) NSUInteger daysInWeek;
@property (assign, nonatomic) NSUInteger originalIndexOfFirstWeekdaySymbol;
@property (assign, nonatomic) NSUInteger originalIndexOfSaturdaySymbol;
@property (assign, nonatomic) NSUInteger originalIndexOfSundaySymbol;

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
    
    [self updateWeekdayLabels];
    [self layoutWeekdayLabels];
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
    
    self.daysInWeek = self.calendar.rsdf_daysInWeek;
    self.originalIndexOfFirstWeekdaySymbol = self.calendar.firstWeekday - 1;
    self.originalIndexOfSaturdaySymbol = self.calendar.rsdf_saturdayIndex - 1;
    self.originalIndexOfSundaySymbol = self.calendar.rsdf_sundayIndex - 1;
    
    NSString *dateFormatterName = [NSString stringWithFormat:@"calendarDaysOfWeekView_%@_%@", [self.calendar calendarIdentifier], [[self.calendar locale] localeIdentifier]];
    NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:dateFormatterName withConstructor:^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:self.calendar];
        [dateFormatter setLocale:[self.calendar locale]];
        return dateFormatter;
    }];
    self.veryShortStandaloneWeekdaySymbols = [dateFormatter veryShortStandaloneWeekdaySymbols];
    self.shortStandaloneWeekdaySymbols = [dateFormatter shortStandaloneWeekdaySymbols];
    self.standaloneWeekdaySymbols = [dateFormatter standaloneWeekdaySymbols];
    
    if (self.originalIndexOfFirstWeekdaySymbol != 0) {
        self.veryShortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.veryShortStandaloneWeekdaySymbols indexOfFirstWeekdaySymbol:self.originalIndexOfFirstWeekdaySymbol];
        self.shortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.shortStandaloneWeekdaySymbols indexOfFirstWeekdaySymbol:self.originalIndexOfFirstWeekdaySymbol];
        self.standaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.standaloneWeekdaySymbols indexOfFirstWeekdaySymbol:self.originalIndexOfFirstWeekdaySymbol];
    }
}

- (void)layoutWeekdayLabels
{
    CGSize itemSize = [self selfItemSize];
    CGFloat interitemSpacing = [self selfInteritemSpacing];
    
    // recalculate the frames
    CGFloat y = 0.0;
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

- (CGFloat)maxWidthOfSymbols:(NSArray *)symbols
{
    CGSize boundingRectSize = CGSizeMake(CGFLOAT_MAX, [self selfItemSize].height);
    UIFont *font = [self dayOfWeekLabelFont];
    
    __block CGFloat maxWidthOfSymbols = 0.0;
    [symbols enumerateObjectsUsingBlock:^(NSString* theString, NSUInteger idx,BOOL *stop) {
        CGFloat currentWidth = ceilf([theString boundingRectWithSize:boundingRectSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil].size.width);
        if (currentWidth >= maxWidthOfSymbols) {
            maxWidthOfSymbols = currentWidth;
        }
    }];
    
    return maxWidthOfSymbols;
}

- (NSUInteger)originalIndexOfWeekdaySymbolFromReorderedIndex:(NSUInteger)reorderedIndex
{
    NSInteger originalIndex = reorderedIndex + self.originalIndexOfFirstWeekdaySymbol;
    if (originalIndex > self.daysInWeek - 1) {
        originalIndex -= self.daysInWeek;
    }
    return originalIndex;
}

- (NSArray *)reorderedWeekdaySymbols:(NSArray *)weekdaySymbols indexOfFirstWeekdaySymbol:(NSUInteger)indexOfFirstWeekdaySymbol
{
    return [[weekdaySymbols subarrayWithRange:NSMakeRange(indexOfFirstWeekdaySymbol, [weekdaySymbols count] - indexOfFirstWeekdaySymbol)]
            arrayByAddingObjectsFromArray:[weekdaySymbols subarrayWithRange:NSMakeRange(0, indexOfFirstWeekdaySymbol)]];
}

- (void)updateWeekdayLabels
{
    NSArray *symbolsToUse;
    
    RSDFDaysOfWeekDisplayStyle style = [self displayStyle];
    if (style == RSDFDaysOfWeekDisplayStyleAuto) {
        
        UIEdgeInsets selfItemInsets = [self selfItemInsets];
        CGFloat maxAvailableItemWidth = [self selfItemSize].width - selfItemInsets.left - selfItemInsets.right;
        
        // first check if the largest one fits
        CGFloat maxWidthOfSymbols = [self maxWidthOfSymbols:self.standaloneWeekdaySymbols];
        if (maxWidthOfSymbols > maxAvailableItemWidth) { // it did not fit
            
            maxWidthOfSymbols = [self maxWidthOfSymbols:self.shortStandaloneWeekdaySymbols];
            if (maxWidthOfSymbols > maxAvailableItemWidth) { // it did not fit -> use very short symbols
                
                symbolsToUse = [self.veryShortStandaloneWeekdaySymbols copy];
            } else {
                symbolsToUse = [self.shortStandaloneWeekdaySymbols copy];
            }
        } else {
            symbolsToUse = [self.standaloneWeekdaySymbols copy];
        }
    } else {
        switch (style) {
            case RSDFDaysOfWeekDisplayStyleLong: {
                symbolsToUse = [self.standaloneWeekdaySymbols copy];
                break;
            }
            case RSDFDaysOfWeekDisplayStyleMedium: {
                symbolsToUse = [self.shortStandaloneWeekdaySymbols copy];
                break;
            }
            case RSDFDaysOfWeekDisplayStyleShort: {
                symbolsToUse = [self.veryShortStandaloneWeekdaySymbols copy];
                break;
            }
            default: {
                NSLog(@"Invalid RSDFDaysOfWeekDisplayStyle. Defaulting to RSDFDaysOfWeekStyleShort");
                symbolsToUse = [self.veryShortStandaloneWeekdaySymbols copy];
                break;
            }
        }
    }
    if (![symbolsToUse isEqualToArray:self.lastSymbolsUsed]){
        // there is now a different set of symbols so we need to reinit/retext the labels
        
        UIFont *dayOfWeekLabelFont = [self dayOfWeekLabelFont];
        
        if (self.weekdayLabels) { // the were already created so just change the text and update the font
            [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
                weekdayLabel.text = [symbolsToUse objectAtIndex:idx];
                weekdayLabel.font = dayOfWeekLabelFont;
            }];
        } else { // the labels have not been created yet
            UIColor *dayOfWeekLabelBackgroundColor = [UIColor clearColor];
            UIColor *dayOfWeekLabelTextColor = [self dayOfWeekLabelTextColor];
            UIColor *dayOffOfWeekLabelTextColor = [self dayOffOfWeekLabelTextColor];
            
            NSMutableArray *weekdayLabels = [NSMutableArray arrayWithCapacity:[symbolsToUse count]];
            [symbolsToUse enumerateObjectsUsingBlock:^(NSString *weekdaySymbol, NSUInteger idx, BOOL *stop) {
                UILabel *weekdayLabel = [[UILabel alloc] init];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                weekdayLabel.backgroundColor = dayOfWeekLabelBackgroundColor;
                weekdayLabel.font = dayOfWeekLabelFont;
                NSUInteger originalIndexOfWeekdaySymbol = [self originalIndexOfWeekdaySymbolFromReorderedIndex:[symbolsToUse indexOfObjectIdenticalTo:weekdaySymbol]];
                if (originalIndexOfWeekdaySymbol != self.originalIndexOfSaturdaySymbol && originalIndexOfWeekdaySymbol != self.originalIndexOfSundaySymbol) {
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
        // update the lastUsedSymbols
        self.lastSymbolsUsed = symbolsToUse;
    }
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
    NSUInteger numberOfItems = self.daysInWeek;
    CGFloat totalInteritemSpacing = [self selfInteritemSpacing] * (numberOfItems - 1);
    
    CGFloat selfItemWidth = (CGRectGetWidth(self.frame) - totalInteritemSpacing) / numberOfItems;
    selfItemWidth = floor(selfItemWidth * 1000) / 1000;
    CGFloat selfItemHeight = CGRectGetHeight(self.frame);
    
    return (CGSize){ selfItemWidth, selfItemHeight };
}

- (UIEdgeInsets)selfItemInsets
{
    return UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0);
}

- (CGFloat)selfInteritemSpacing
{
    return 2.0f;
}

- (RSDFDaysOfWeekDisplayStyle)displayStyle
{
    return RSDFDaysOfWeekDisplayStyleAuto;
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

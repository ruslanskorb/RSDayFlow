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
@property (nonatomic, copy) NSArray *lastSymbolsUsed;

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
    
    NSString *dateFormatterName = [NSString stringWithFormat:@"calendarDaysOfWeekView_%@_%@", [self.calendar calendarIdentifier], [[self.calendar locale] localeIdentifier]];
    NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:dateFormatterName withConstructor:^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:self.calendar];
        [dateFormatter setLocale:[self.calendar locale]];
        return dateFormatter;
    }];
    self.veryShortStandaloneWeekdaySymbols = [dateFormatter veryShortStandaloneWeekdaySymbols];
    self.shortStandaloneWeekdaySymbols  = [dateFormatter shortStandaloneWeekdaySymbols];
    self.standaloneWeekdaySymbols = [dateFormatter standaloneWeekdaySymbols];
    
    // weekday start from 1
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        self.veryShortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.veryShortStandaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
        self.shortStandaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.shortStandaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
        self.standaloneWeekdaySymbols = [self reorderedWeekdaySymbols:self.standaloneWeekdaySymbols firstWeekdayIndex:firstWeekdayIndex];
    }
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
    
    //recalculate the Frames
    CGFloat y = 0;
    __block CGFloat x = 0;
    
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
        CGRect weekdayLabelFrame = CGRectMake(x, y, itemSize.width, itemSize.height);
        weekdayLabel.frame = weekdayLabelFrame;
        x += (itemSize.width + interitemSpacing);
    }];
}

-(void)updateWeekdayLabels{
    NSArray *symbolsToUse;
    
    RSDFDaysOfWeekDisplayStyle theStyle = [self displayStyle];
    if(theStyle == RSDFDaysOfWeekDisplayStyleAuto){
        
        CGSize maxItemSize = [self selfItemSize];
        CGFloat maxAvailableItemWidth = [self selfItemSize].width;
        UIFont *currentFont = [self dayOfWeekLabelFont];
        
        __block CGFloat maxWidthOfSymbols = 0;
        //first check if the largest one fits
        [_standaloneWeekdaySymbols enumerateObjectsUsingBlock:^(NSString* theString, NSUInteger idx,BOOL *stop){
            CGFloat currentWidth =[theString boundingRectWithSize:maxItemSize options:0 attributes:@{ NSFontAttributeName:currentFont } context:nil].size.width;
            if(currentWidth >= maxWidthOfSymbols){
                maxWidthOfSymbols = currentWidth;
            }
        }];
        if(maxWidthOfSymbols > maxAvailableItemWidth){//it did not fit
            maxWidthOfSymbols = 0; //reset the Coumter
            [_shortStandaloneWeekdaySymbols enumerateObjectsUsingBlock:^(NSString* theString, NSUInteger idx,BOOL *stop){
                CGFloat currentWidth =[theString boundingRectWithSize:maxItemSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:currentFont } context:nil].size.width;
                if(currentWidth >= maxWidthOfSymbols){
                    maxWidthOfSymbols = currentWidth;
                }
            }];
            if(maxWidthOfSymbols > maxAvailableItemWidth){//it did not fit -> use very short symbols
                symbolsToUse = [self.veryShortStandaloneWeekdaySymbols copy];
            }
            else{
                symbolsToUse = [self.shortStandaloneWeekdaySymbols copy];
            }
        }
        else{
            symbolsToUse = [self.standaloneWeekdaySymbols copy];
        }
    }
    else{
        if(theStyle == RSDFDaysOfWeekDisplayStyleLong){
            symbolsToUse = [self.standaloneWeekdaySymbols copy];
        }
        else if(theStyle == RSDFDaysOfWeekDisplayStyleMedium){
            symbolsToUse = [self.shortStandaloneWeekdaySymbols copy];
        }
        else if(theStyle == RSDFDaysOfWeekDisplayStyleShort){
            symbolsToUse = [self.veryShortStandaloneWeekdaySymbols copy];
        }
        else{
            NSLog(@"Invalid RSDFDaysOfWeekDisplayStyle. Defaulting to RSDFDaysOfWeekStyleShort");
            symbolsToUse = [self.veryShortStandaloneWeekdaySymbols copy];
        }
    }
    if(![symbolsToUse isEqualToArray:self.lastSymbolsUsed]){
        //there is now a different set of Symbols so we need to reinit/retext the Labels
        if(self.weekdayLabels){//the were already created so just change the text
            [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger idx, BOOL *stop) {
                weekdayLabel.text = [symbolsToUse objectAtIndex:idx];
            }];
        }
        else{//the Labels have not been created yet
            UIColor *dayOfWeekLabelBackgroundColor = [UIColor clearColor];
            UIFont *dayOfWeekLabelFont = [self dayOfWeekLabelFont];
            UIColor *dayOfWeekLabelTextColor = [self dayOfWeekLabelTextColor];
            UIColor *dayOffOfWeekLabelTextColor = [self dayOffOfWeekLabelTextColor];
            
            NSMutableArray *weekdayLabels = [NSMutableArray arrayWithCapacity:[symbolsToUse count]];
            [symbolsToUse enumerateObjectsUsingBlock:^(NSString *weekdaySymbol, NSUInteger idx, BOOL *stop) {
                UILabel *weekdayLabel = [[UILabel alloc] init];
                weekdayLabel.textAlignment = NSTextAlignmentCenter;
                weekdayLabel.backgroundColor = dayOfWeekLabelBackgroundColor;
                weekdayLabel.font = dayOfWeekLabelFont;
                if ([symbolsToUse indexOfObjectIdenticalTo:weekdaySymbol] != 0 && [symbolsToUse indexOfObjectIdenticalTo:weekdaySymbol] != 6) {
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
        //Update the lastUsedSymbols
        self.lastSymbolsUsed = symbolsToUse;
    }
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

- (RSDFDaysOfWeekDisplayStyle) displayStyle{
    return RSDFDaysOfWeekDisplayStyleAuto;
}

#pragma mark - Attributes of Subviews

- (UIFont *)dayOfWeekLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
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

//
// NSCalendar+RSDFAdditions.m
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

#import "NSCalendar+RSDFAdditions.h"

@implementation NSCalendar (RSDFAdditions)

- (NSDateFormatter *)df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block
{
	//	We can not use objc_setAssociatedObject() because it has no thread safety
	//	Modeled after http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
	//	Intended for use where there are a myriad of date formatters keyed on a calendar
	
	NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = threadDictionary[name];
	
	if (!dateFormatter) {
		dateFormatter = block();
		threadDictionary[name] = dateFormatter;
	}
	
	return dateFormatter;
}

- (NSUInteger)rsdf_daysInWeek
{
    return [self maximumRangeOfUnit:NSCalendarUnitWeekday].length;
}

- (NSUInteger)rsdf_saturdayIndex
{
    return 7;
}

- (NSUInteger)rsdf_sundayIndex
{
    return 1;
}

@end

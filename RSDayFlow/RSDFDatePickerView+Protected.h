//
// RSDFDatePickerView+Protected.h
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

#import "RSDFDatePickerView.h"

/**
 The methods in the RSDFDatePickerViewProtectedMethods category
 typically should only be called by subclasses which are implementing new
 date picker views. If you override one you must call super.
 */
@interface RSDFDatePickerView (RSDFDatePickerViewProtectedMethods)

/**
 Returns the date that corresponds to the specified cell in the date picker view.
 
 @param indexPath The index path that specifies the location of the cell.
 
 @return The date that corresponds to the specified cell in the date picker view.
 */
- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the date of the first day of the month that corresponds to the specified section in the date picker view.
 
 @param section The section that specifies the location of the month.
 
 @return The date of the first day of the month that corresponds to the specified section in the date picker view.
 */
- (NSDate *)dateForFirstDayInSection:(NSInteger)section;

@end

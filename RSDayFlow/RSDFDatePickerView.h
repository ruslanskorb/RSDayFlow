//
// RSDFDatePickerView.h
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

@class RSDFDatePickerDayCell;
@protocol RSDFDatePickerViewDelegate;
@protocol RSDFDatePickerViewDataSource;

typedef NS_ENUM (NSUInteger, RSDFSelectionMode) {
    
    /// Allows selecting a single date
    RSDFSelectionModeSingle,

    /// Allows selecting multiple dates
    RSDFSelectionModeMultiple,
    
    /// Allows selecting a date range (start range & end range)
    RSDFSelectionModeRange
};

/**
 The `RSDFDatePickerView` is a calendar view with infinity scrolling.
*/
@interface RSDFDatePickerView : UIView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 Designated initializer. Initializes and returns a newly allocated view object with the specified frame rectangle and the specified calendar.
 
 @param frame The frame rectangle for the view, measured in points.
 @param calendar The calendar for the date picker view.
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar * __nonnull)calendar;


/**
 Designated initializer. Initializes and returns a newly allocated view object with the specified frame rectangle and the specified calendar.
 
 @param frame The frame rectangle for the view, measured in points.
 @param calendar The calendar for the date picker view.
 @param startDate First selectable date
 @param endDate Last selectable date
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar * __nonnull)calendar startDate:(NSDate * __nullable)startDate endDate:(NSDate * __nullable)endDate;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.
 
 @discussion A `RSDFDatePickerView` delegate responds to message sent by tapping on date in the date picker view.
 */
@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDelegate> __nullable delegate;

///--------------------------------
/// @name Accessing the Data Source
///--------------------------------

/**
 The receiver's data source.
 
 @discussion A `RSDFDatePickerView` data source provides dates to mark in the date picker view.
 */

@property (nonatomic, readwrite, weak) id<RSDFDatePickerViewDataSource> __nullable dataSource;

///------------------
/// @name Selection Mode
/// -----------------

/**
   Am enum that determines date selection type
  
   @discussion Default values is RSDFSelectionModeSingle
   If 'RSDFSelectionModeSingle' only allows a single date to be selected
   If 'RSDFSelectionModeRange' allows selecting a date range (start date and end date)
   */
@property (nonatomic, readwrite, assign) RSDFSelectionMode selectionMode;

///------------------
/// @name Paging Mode
/// -----------------

/**
 A Boolean value that determines whether paging is enabled for the date picker view. Default value is `NO`.
 
 @discussion If `YES`, stop on the top of the month.
 */
@property (nonatomic, getter = isPagingEnabled) BOOL pagingEnabled;

///----------------------------
/// @name Scrolling to the Date
///----------------------------

/**
 Scrolls the date picker view to the current day.
 
 @param animated YES if you want to animate the change in position, NO if it should be immediate.
 */

- (void)scrollToToday:(BOOL)animated;

/**
 Scrolls the date picker view to the given date.
 
 @param animated YES if you want to animate the change in position, NO if it should be immediate.
 */

- (void)scrollToDate:(NSDate * __nonnull)date animated:(BOOL)animated;

/// ------------------------
/// @name Selecting the Date
/// ------------------------

/**
 Selects the specified date.
 
 If there is an existing selection of a different date, calling this method replaces the previous selection.
 
 This method does not cause any selection-related delegate methods to be called.
 
 @param date The date to select. Specifying nil for this parameter clears the current selection.
 */

- (void)selectDate:(NSDate * __nullable)date;

/**
 Selects dates in range.
 
 If there is an existing selection of a different date, calling this method replaces the previous selection.
 
 This method does not cause any selection-related delegate methods to be called.
 
 @param firstDate The start range date to select.
 @param lastDate The end range date to select.
 */
- (void)selectDateRange:(NSDate * __nullable)firstDate lastDate:(NSDate * __nullable)lastDate;

/**
Deselect dates
 
 @param animated if tru animates using standard collectionView animation
 */
- (void)deselectDatesAnimated:(BOOL)animated;

///-------------------------
/// @name Reloading the Data
///-------------------------

/**
 Reloads all of the data for the date picker view.
 
 @discussion Discard the dataSource and delegate data and requery as necessary.
 */
- (void)reloadData;

///------------------------------------
/// @name Accessing Classes of Subviews
///------------------------------------

/**
 The class of the view with labels for each day of the week. Default value is `RSDFDatePickerDaysOfWeekView`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (Class __nonnull)daysOfWeekViewClass;

/**
 The class of the collection view which used to display days and months in the date picker view. Default value is `RSDFDatePickerCollectionView`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (Class __nonnull)collectionViewClass;

/**
 The class of the layout of the collection view which used the date picker. Default value is `RSDFDatePickerCollectionViewLayout`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (Class __nonnull)collectionViewLayoutClass;

/**
 The class of the reusable view which used to display a month and year in the date picker view. Default value is `RSDFDatePickerMonthHeader`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (Class __nonnull)monthHeaderClass;

/**
 The class of the cell which used to display a day in the date picker view. Default value is `RSDFDatePickerDayCell`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (Class __nonnull)dayCellClass;

@end

/**
 The `RSDFDatePickerViewDelegate` protocol defines the message sent to a date picker view delegate when date is tapped.
 */
@protocol RSDFDatePickerViewDelegate <NSObject>

///-----------------------------------
/// @name Responding to Date Selection
///-----------------------------------

@optional

/**
 Asks the delegate if the date should be highlighted during tracking.
 
 As touch events arrive, the date picker view highlights dates in anticipation of the user selecting them.
 As it processes those touch events, the date picker view calls this method to ask your delegate if a given cell should be highlighted.
 
 If you do not implement this method, the default return value is YES.
 
 @param view The date picker view object that is asking about the highlight change.
 
 @return YES if the date should be highlighted or NO if it should not.
 */
- (BOOL)datePickerView:(RSDFDatePickerView * __nonnull)view shouldHighlightDate:(NSDate * __nonnull)date;

/**
 Asks the delegate if the specified date should be selected.
 
 The date picker view calls this method when the user tries to select a date in the date picker view.
 It does not call this method when you programmatically set the selection.
 
 If you do not implement this method, the default return value is YES.
 
 @param view The date picker view object that is asking whether the date should select.
 
 @return YES if the date should be selected or NO if it should not.
 */
- (BOOL)datePickerView:(RSDFDatePickerView * __nonnull)view shouldSelectDate:(NSDate * __nonnull)date;

/**
 Tells the delegate that the user did select a date.
 
 The date picker view calls this method when the user successfully selects a date in the date picker view.
 It does not call this method when you programmatically set the selection.
 
 @param view The view whose date was selected.
 @param date The selected date.
 */
- (void)datePickerView:(RSDFDatePickerView * __nonnull)view didSelectDate:(NSDate * __nonnull)date;

/**
 Tells the delegate that the user did select a date in RSDFSelectionModeRange.
 
 The date picker view calls this method when the user successfully selects a date in the date picker view.
 It does not call this method when you programmatically set the selection.
 
 @param view The view whose date was selected.
 @param startDate The selected start date for range.
 @param endDate The selected end date for range.
 */
- (void)datePickerView:(RSDFDatePickerView * __nonnull)view didSelectStartDate:(NSDate * __nullable)startDate endDate:(NSDate * __nullable)endDate;

/**
 Tells the delegate that the user did select a date in RSDFSelectionModeRange.
 
 The date picker view calls this method when the user successfully selects a date in the date picker view.
 It does not call this method when you programmatically set the selection.
 
 @param view The view whose date was selected.
 @param startDate The selected start date for range.
 @param endDate The selected end date for range.
 */
- (void)datePickerView:(RSDFDatePickerView * __nonnull)view didSelectDates:(NSArray<NSDate *> * __nonnull)dates;

/**
Called after the layout is complete on each cell, and alow customizing cells based on custom logic and based on specific dates
 */
- (void)datePickerView:(RSDFDatePickerView * __nonnull)view didDisplayCell:(RSDFDatePickerDayCell * __nonnull)cell;

@end

/**
 The `RSDFDatePickerViewDataSource` protocol is adopted by an object that provides dates to mark in the date picker view.
 */
@protocol RSDFDatePickerViewDataSource <NSObject>

///------------------------------
/// @name Providing Dates to Mark
///------------------------------

@optional

/**
 Asks the data source if the date should be marked.
 
 @param view The date picker view object that is asking whether the date should mark.
 
 @return YES if the date should be marked or NO if it should not.
 */
- (BOOL)datePickerView:(RSDFDatePickerView * __nonnull)view shouldMarkDate:(NSDate * __nonnull)date;

/**
 Asks the data source about the color of the default mark image for the specified date.
 
 @param view The date picker view object that is asking about the color of the default mark image for the specified date.
 
 @return The color of the default mark image for the specified date.
 
 @discussion Will be ignored if the method `datePickerView:markImageForDate:` is implemented.
 */
- (UIColor * __nonnull)datePickerView:(RSDFDatePickerView * __nonnull)view markImageColorForDate:(NSDate * __nonnull)date;

/**
 Asks the data source about the mark image for the specified date.
 
 @param view The date picker view object that is asking about the mark image for the specified date.
 
 @return The mark image for the specified date.
 */
- (UIImage * __nonnull)datePickerView:(RSDFDatePickerView * __nonnull)view markImageForDate:(NSDate * __nonnull)date;

@end

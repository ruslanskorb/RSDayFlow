//
// RSDFDatePickerCollectionView.h
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

#import <UIKit/UIKit.h>

@class RSDFDatePickerCollectionView;

/**
 The `RSDFDatePickerCollectionViewDelegate` protocol defines the message sent to a collection view delegate when the collection view will layout subviews.
 */
@protocol RSDFDatePickerCollectionViewDelegate <UICollectionViewDelegate>

///---------------------------------
/// @name Supporting Layout Subviews
///---------------------------------

/**
 Tells the delegate that the collection view will layout subviews.
 
 @param pickerCollectionView The collection view which will layout subviews.
 */
- (void) pickerCollectionViewWillLayoutSubviews:(RSDFDatePickerCollectionView *)pickerCollectionView;

@end


/**
 The `RSDFDatePickerCollectionView` is a collection view which used to display days and months in the date picker view.
 */
@interface RSDFDatePickerCollectionView : UICollectionView

/**
 The receiver's delegate.
 
 @discussion A `RSDFDatePickerCollectionView` delegate uses to support layout subviews in the date picker view.
 */
@property (nonatomic, assign) id <RSDFDatePickerCollectionViewDelegate> delegate;

///---------------------------------------
/// @name Accessing Attributes of the View
///---------------------------------------

/**
 The view’s background color. Default value is `[UIColor whiteColor]`.
 
 @discussion Can be overridden in subclasses for customization.
 */
- (UIColor *)selfBackgroundColor;

@end

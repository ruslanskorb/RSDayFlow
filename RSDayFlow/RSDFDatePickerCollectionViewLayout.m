//
// RSDFDatePickerCollectionViewLayout.m
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

#import "RSDFDatePickerCollectionViewLayout.h"

@implementation RSDFDatePickerCollectionViewLayout

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
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
    //	Hard key these things.
    //	44 * 7 + 2 * 6 = 320; this is how the Calendar.app works
    //	and this also avoids the “one pixel” confusion which might or might not work
    //	If you need to decorate, key decorative views in.
    
    self.headerReferenceSize = [self selfHeaderReferenceSize];
    self.itemSize = [self selfItemSize];
    self.minimumLineSpacing = [self selfMinimumLineSpacing];
    self.minimumInteritemSpacing = [self selfMinimumInteritemSpacing];
}

#pragma mark - Atrributes of the Layout

- (CGSize)selfHeaderReferenceSize
{
    return (CGSize){ 320, 64 };
}

- (CGSize)selfItemSize
{
    return (CGSize){ 44, 70 };
}

- (CGFloat)selfMinimumLineSpacing
{
    return 2.0f;
}

- (CGFloat)selfMinimumInteritemSpacing
{
    return 2.0f;
}

@end

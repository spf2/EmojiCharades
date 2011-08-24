//
//  YKLayout.m
//  YelpIPhone
//
//  Created by Gabriel Handford on 1/31/11.
//  Copyright 2011 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "YKLayout.h"
#import "YKCGUtils.h"
#import "YKDefines.h"


@interface YKLayout ()
- (CGSize)_layout:(CGSize)size apply:(BOOL)apply;
@end

static NSMutableDictionary *gDebugStats = NULL;


@implementation YKLayout

@synthesize debugEnabled=_debugEnabled, sizeThatFits=_sizeThatFits;

- (id)init {
  [NSException raise:NSDestinationInvalidException format:@"Layout must be associated with a view; Use initWithView:"];
  return nil;
}

- (id)initWithView:(UIView *)view {
  if ((self = [super init])) {
    
    if (![view respondsToSelector:@selector(layout:size:)]) {
      [NSException raise:NSObjectNotAvailableException format:@"Layout is not supported for this view. Implement layout:size:."];
      return nil;
    }
    
    _cachedSize = CGSizeZero;
    _accessibleElements = [[NSMutableArray alloc] init];
    _view = view; // weak reference
    _sizeThatFits = CGSizeZero;
    _needsLayout = YES;
    _needsSizing = YES;
#if DEBUG
    YKLayoutStats *stats = [YKLayout statsForView:_view];
    stats->_createCount++;
#endif
  }
  return self;
}

- (void)dealloc {
  [_subviews release];
  [_accessibleElements release];
  [super dealloc];
}

- (NSArray *)accessibleElements {
  return _accessibleElements;
}

+ (YKLayout *)layoutForView:(UIView *)view {
  return [[[YKLayout alloc] initWithView:view] autorelease];
}

- (CGSize)_layout:(CGSize)size apply:(BOOL)apply {
#if DEBUG
  YKLayoutStats *stats = [YKLayout statsForView:_view];
#endif
  
  if (YKCGSizeIsEqual(size, _cachedSize) && ((!_needsSizing && !apply) || (!_needsLayout && apply))) {
#if DEBUG
    stats->_cacheCount++;
#endif
    return _cachedLayoutSize;
  }
  
  _apply = apply;
  _cachedSize = size;
  if (_apply) {
    // Remove previous accessible elements before they're recreated in layout:size:()
    [_accessibleElements removeAllObjects];
  }
#if DEBUG
  NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
#endif
  CGSize layoutSize = [(id<YKUIViewLayout>)_view layout:self size:size];
#if DEBUG
  stats->_timing += [NSDate timeIntervalSinceReferenceDate] - time;
  stats->_layoutCount++;
#endif
  _cachedLayoutSize = layoutSize;
  if (_apply) {
    _needsLayout = NO;
  }
  _needsSizing = NO;
  _apply = NO;    
  //[stats.log addObject:[NSString stringWithFormat:@"(%@)=>%@", NSStringFromCGSize(size), NSStringFromCGSize(layoutSize)]];
  return layoutSize;
}

- (void)setNeedsLayout {
  _needsLayout = YES;
  _needsSizing = YES;
  _cachedSize = CGSizeZero;
}

- (CGSize)layoutSubviews:(CGSize)size {
  CGSize layoutSize = [self _layout:size apply:YES];  
  for (id view in _subviews) {
    [view layoutIfNeeded];
  }
  return layoutSize;
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (_sizeThatFits.width > 0 && _sizeThatFits.height > 0) return _sizeThatFits;
  if (_sizeThatFits.width > 0) size = _sizeThatFits;
  return [self _layout:size apply:NO];
}

- (CGRect)setFrame:(CGRect)frame view:(UIView *)view sizeToFit:(BOOL)sizeToFit {
  return [self setFrame:frame view:view options:(sizeToFit ? YKLayoutOptionsSizeToFit : 0)];
}

- (CGRect)setFrame:(CGRect)frame view:(UIView *)view options:(YKLayoutOptions)options {
  CGRect originalFrame = frame;
  BOOL sizeToFit = ((options & YKLayoutOptionsSizeToFit) == YKLayoutOptionsSizeToFit);
  CGSize sizeThatFits = CGSizeZero;
  if (sizeToFit) {
    sizeThatFits = [view sizeThatFits:frame.size];
    
    // If size that fits returns a larger width, then we'll need to constrain it.
    if (((options & YKLayoutOptionsSizeToFitConstraintWidth) == YKLayoutOptionsSizeToFitConstraintWidth) && sizeThatFits.width > frame.size.width) {
      sizeThatFits.width = frame.size.width;
    }
    
    if (sizeThatFits.width == 0 && ((options & YKLayoutOptionsSizeToFitDefaultSize) == YKLayoutOptionsSizeToFitDefaultSize)) {
      sizeThatFits.width = frame.size.width;
    }
    
    if (sizeThatFits.height == 0 && ((options & YKLayoutOptionsSizeToFitDefaultSize) == YKLayoutOptionsSizeToFitDefaultSize)) {
      sizeThatFits.height = frame.size.height;
    }
    
    //NSAssert(sizeThatFits.width > 0, @"sizeThatFits: on view returned 0 width; Make sure that layout:size: doesn't return a zero width size");
    
    frame.size = sizeThatFits;
  }
  
  BOOL center = ((options & YKLayoutOptionsCenter) == YKLayoutOptionsCenter);
  BOOL centerVertical = ((options & YKLayoutOptionsCenterVertical) == YKLayoutOptionsCenterVertical);
  if (center || centerVertical) {
    //if (!sizeToFit) sizeThatFits = [view sizeThatFits:frame.size];
    CGSize sizeToCenter = frame.size;
    if (center) {
      frame = YKCGRectToCenterInRect(sizeToCenter, originalFrame);
    } else if (centerVertical) {
      frame = YKCGRectToCenterY(CGRectMake(frame.origin.x, frame.origin.y, sizeToCenter.width, sizeToCenter.height), originalFrame);
    }
  }
  
  [self setFrame:frame view:view];
  return frame;  
}

- (CGRect)setX:(CGFloat)x view:(UIView *)view {
  CGRect frame = view.frame;
  frame.origin.x = x;
  return [self setFrame:frame view:view];
}

- (CGRect)setY:(CGFloat)y view:(UIView *)view {
  CGRect frame = view.frame;
  frame.origin.y = y;
  return [self setFrame:frame view:view];
}

- (CGRect)setOrigin:(CGPoint)origin view:(UIView *)view {
  CGRect frame = view.frame;
  frame.origin = origin;
  return [self setFrame:frame view:view];
}

- (CGRect)setFrame:(CGRect)frame view:(UIView *)view {
  if (!view) return CGRectZero;
  if (_apply) {
    view.frame = frame;
    if (view) {
      [_accessibleElements addObject:view];
    }
    // Since we are applying the frame, the subview will need to
    // apply their layout next at this frame
    [view setNeedsLayout];
  }
  // Some stupid views (cough UIPickerView cough) will snap to certain frame
  // values. This makes sure we return the actual frame of the view
  if (_apply) return view.frame;
  return frame;
}

- (BOOL)isSizing {
  return !_apply;
}

- (void)addSubview:(UIView *)view {
#if YP_DEBUG
  if (![view respondsToSelector:@selector(drawInRect:)]) {
    [NSException raise:NSInvalidArgumentException format:@"Subview should implement the method - (void)drawInRect:(CGRect)rect;"];
    return;
  }
  if (![view respondsToSelector:@selector(frame)]) {
    [NSException raise:NSInvalidArgumentException format:@"Subview should implement the method - (CGRect)frame;"];
    return;
  }
  if (![view respondsToSelector:@selector(isHidden)]) {
    [NSException raise:NSInvalidArgumentException format:@"Subview should implement the method - (BOOL)isHidden;"];
    return;
  }
#endif
  if (!_subviews) _subviews = [[NSMutableArray alloc] init];
  [_subviews addObject:view];
}

- (void)clear {
  _view = nil;
  [_subviews removeAllObjects];
}

- (void)removeSubview:(UIView *)view {
  [_subviews removeObject:view];
}

- (void)drawSubviewsInRect:(CGRect)rect {
  for (id view in _subviews) {
    if (![view isHidden]) {
      [view drawInRect:CGRectOffset([view frame], rect.origin.x, rect.origin.y)];
    }
  }
}

void YKLayoutAssert(UIView *view, id<YKLayout> layout) {
#if DEBUG
  if ([view respondsToSelector:@selector(layout:size:)] && !layout) {
    [NSException raise:NSObjectNotAvailableException format:@"Missing layout instance for %@", view];
  }
  if (![view respondsToSelector:@selector(layout:size:)] && layout) {
    [NSException raise:NSObjectNotAvailableException format:@"Missing layout:size: for %@", view];
  }
#endif
}

+ (YKLayoutStats *)statsForView:(UIView *)view {
  NSString *name = NSStringFromClass([view class]);
  if (gDebugStats == NULL) gDebugStats = [[NSMutableDictionary alloc] init];
  YKLayoutStats *stats = [gDebugStats objectForKey:name];
  if (!stats) {
    stats = [[YKLayoutStats alloc] init];
    [gDebugStats setObject:stats forKey:name];
    [stats release];
  }
  return stats;
}

+ (void)dumpStats {
#if DEBUG
  YKDebug(@"\n\n");
  YKDebug(@"Layout stats");
  YKDebug(@"-------------------------------------");
  for (NSString *name in gDebugStats) {
    YKDebug(@"name=%@, stats=%@", name, [gDebugStats objectForKey:name]);
  }
  YKDebug(@"-------------------------------------\n\n");
  [gDebugStats release];
  gDebugStats = nil;
#endif
}

@end


@implementation YKLayoutStats

@synthesize log=_log;

- (id)init {
  if ((self = [super init])) {
    _log = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_log release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"layoutCount=%d, cacheCount=%d, createCount=%d, timing=%0.3f, log=%@", _layoutCount, _cacheCount, _createCount, _timing, [_log componentsJoinedByString:@","]];
}

@end
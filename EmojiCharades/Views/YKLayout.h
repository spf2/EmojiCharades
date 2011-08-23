//
//  YKLayout.h
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

/*!
 YKLayout options used in 
 
 @code
   - (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size;
 @endcode
 
 If option YKLayoutOptionsSizeToFit, then the view width may be shrunk, 
 you can also pass in a 0 height, if it is variable.
 
 For example, 
  @code
  CGRect titleLabelFrame = [layout setFrame:CGRectMake(x, y, 400, 0) view:_titleLabel options:YKLayoutOptionsSizeToFit];
  // titleLabelFrame may have a different width and will have a valid height
  @endcode
 
 You can combine YKLayoutOptionsSizeToFit and YKLayoutOptionsCenter to have it be centered with a variable height. 
 For example,
  @code
  CGRect titleLabelFrame = [layout setFrame:CGRectMake(x, y, 400, 0) view:_titleLabel options:YKLayoutOptionsSizeToFit|YKLayoutOptionsCenter];
  // titleLabelFrame may have a different width and will have a valid height and will have an x position so it is centered
  @endcode
  
 You can also combine YKLayoutOptionsSizeToFit with YKLayoutOptionsConstraintWidth 
 to make sure the width isn't set larger than expected. For example, 
  @code
  CGRect titleLabelFrame = [layout setFrame:CGRectMake(x, y, 400, 0) view:_titleLabel options:YKLayoutOptionsSizeToFit|YKLayoutOptionsConstraintWidth];
  // titleLabelFrame may have a different width but it won't be larger than 400
  @endcode

 You can combine YKLayoutOptionsSizeToFit, YKLayoutOptionsConstraintWidth, and YKLayoutOptionsDefaultWidth to make sure
 a view sizes to fit with max and default width (when 0).  
 */
typedef enum {
  YKLayoutOptionsSizeToFit = 1 << 0, // Whether to sizeToFit the view
  YKLayoutOptionsCenter = 1 << 1, // Whether to center the view in the specified size
  YKLayoutOptionsCenterVertical = 1 << 2, // Whether to center vertically
  
  // Whether sizeToFit is constrained to the width specified.
  // For example UILabel sizeToFit may return a larger width than was specified,
  // and this will constrain it.
  YKLayoutOptionsSizeToFitConstraintWidth = 1 << 3,
  
  // Whether the size specified is the default. Using this option will
  // use the specified width and/or height (if not 0) when the sizeToFit 
  // returns a 0 width.
  // This is useful for an image view that has to load its data and may 
  // initially return 0 for sizeThatFits.
  // This option is only available when using 
  YKLayoutOptionsSizeToFitDefaultSize = 1 << 4, 
} YKLayoutOptions;


/*!
 YKLayout is designed to calculate and return a size that best fits the receiver’s subviews,
 without altering the subviews frames, or affecting layoutSubviews call hierarchy.
 */
@protocol YKLayout <NSObject>

/*!
 Layout the subviews.
 @param size Size to layout in
 */
- (CGSize)layoutSubviews:(CGSize)size;

/*!
 Size that fits.
 @param size Size to layout in; Should have a width specified.
 @result The size needed to display the view
 */
- (CGSize)sizeThatFits:(CGSize)size;

/*!
 Set frame for the (sub)view.
 If we are calculating sizeThatFits, this doesn't actually set the views frame.
 @param frame
 @param view
 */
- (CGRect)setFrame:(CGRect)frame view:(UIView *)view;

/*!
 Set the (sub)view frame, then size to fit the view.
 If we are calculating sizeThatFits, this doesn't actually set the views frame.
 @param frame
 @param view
 @param sizeToFit
 @result The view frame. 
    Use this value instead of view.frame since the views frame might not have been set.
 */
- (CGRect)setFrame:(CGRect)frame view:(UIView *)view sizeToFit:(BOOL)sizeToFit;

/*!
 Set the (sub)view frame.
 If we are calculating sizeThatFits, this doesn't actually set the views frame.
 @param view
 @param options Options for setFrame; See YKLayoutOptions for more info
 @result The view frame. 
    Use this value instead of view.frame since the views frame might not have been set.
 */
- (CGRect)setFrame:(CGRect)frame view:(UIView *)view options:(YKLayoutOptions)options;

/*!
 Set origin for the (sub)view (for views with fixed sizes).
 If we are calculating sizeThatFits, this doesn't actually set the views frame.
 @param origin
 @param view
 @result The view frame. 
    Use this value instead of view.frame since the views frame might not have been set.
 */
- (CGRect)setOrigin:(CGPoint)origin view:(UIView *)view;

/*!
 Set origin, x position.
 @param x
 @param view
 @result The view frame. 
 Use this value instead of view.frame since the views frame might not have been set.
 */
- (CGRect)setX:(CGFloat)x view:(UIView *)view;

/*!
 Set origin, y position.
 @param y
 @param view
 @result The view frame. 
 Use this value instead of view.frame since the views frame might not have been set.
 */
- (CGRect)setY:(CGFloat)y view:(UIView *)view;

/*!
 If layout is required. Otherwise cached value may be returned.
 This should be called when a views data changes.
 */
- (void)setNeedsLayout;

/*!
 For subclasses, in rare cases, if they need to know whether the layout will
 be applied or not via setFrame:view:
 @result YES if we are only sizing, NO if we are setting frames
 */
- (BOOL)isSizing;

@end


/*!
 UIView's can implement this protocol, to enable custom layouts.
 */
@protocol YKUIViewLayout <NSObject>
- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size;
@end

/*!
 Subviews added to YKLayout need to implement these methods.
 */
@protocol YKLayoutDrawable <NSObject>
- (CGRect)frame;
- (BOOL)isHidden;
- (void)layoutIfNeeded;
- (void)drawInRect:(CGRect)rect;
@end

@class YKLayoutStats;


/*!
 Layout manager, default.
 
 If setting the layout, your view should implement the YKUIViewLayout protocol.
 */
@interface YKLayout : NSObject <YKLayout> { 
  
  UIView *_view; // weak
  
  BOOL _needsLayout;
  BOOL _needsSizing;
  CGSize _cachedSize;
  CGSize _cachedLayoutSize;
  NSMutableArray *_accessibleElements;
  
  BOOL _apply;
  
  NSMutableArray */*of UIView*/_subviews; // For manual subview handling
  
  CGSize _sizeThatFits;
  
  BOOL _debugEnabled;  
}

@property (readonly, retain, nonatomic) NSArray *accessibleElements;

/*!
 Set a custon/fixed size that fits.
 Override the size that is returned by sizeThatFits:(CGSize)size.
 Defaults to CGSizeZero, which is unset.
 If height is not set (is 0), then we will use this size value for sizeThatFits:.
 */
@property (assign, nonatomic) CGSize sizeThatFits;

@property (assign, nonatomic) BOOL debugEnabled;

/*!
 Create layout for view.
 @param view View for layout (weak reference).
 */
- (id)initWithView:(UIView *)view;

/*!
 Default layout.
 @param view View for layout (weak reference).
 @result Layout
 */
+ (YKLayout *)layoutForView:(UIView *)view;

/*!
 Add subview.

 Call YKLayout#drawSubviews in the superview drawRect: method to
 draw YKLayout managed subviews.

 Subviews managed by the layout don't automatically handle re-display,
 or touches. Layout managed subviews are intended for simple views
 or views in table view cells that need better scrolling performance.
 For resizing you may need to adjust the contentMode.
 @param view
 */
- (void)addSubview:(UIView *)view;

/*!
 Remove subview.
 @param view
 */
- (void)removeSubview:(UIView *)view;

/*!
 Draw subviews that were added.
 Each view is draw at their view frame.
 @param rect Offset to draw in; TODO(gabe): Use rect.size?
 */
- (void)drawSubviewsInRect:(CGRect)rect;

/*!
 Remove view reference and all subviews.
 */
- (void)clear;

/*!
 Get debug stats.
 */
+ (YKLayoutStats *)statsForView:(UIView *)view;

+ (void)dumpStats;

/*!
 Assert layout parameters are correct.
 */
void YKLayoutAssert(UIView *view, id<YKLayout> layout);

@end


@interface YKLayoutStats : NSObject {
  NSMutableArray *_log;
  
@public
  NSTimeInterval _timing;
  NSInteger _createCount;
  NSInteger _layoutCount;
  NSInteger _cacheCount;
}

@property (readonly, nonatomic) NSMutableArray *log;

@end

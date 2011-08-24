//
//  YKCGUtils.m
//  YelpKit
//
//  Created by Gabriel Handford on 12/30/08.
//  Copyright 2008 Yelp. All rights reserved.
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

#import "YKCGUtils.h"
#import "YKDefines.h"

void _YKCGContextDrawStyledRect(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius);
void _horizontalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out, BOOL reverse);
void _metalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out);
void _horizontalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _horizontalReverseEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _metalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _linearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _exponentialColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _colorReleaseInfoFunction(void *info);

const CGPoint YKCGPointNull = {CGFLOAT_MAX, CGFLOAT_MAX};

bool YKCGPointIsNull(CGPoint point) {
  return point.x == YKCGPointNull.x && point.y == YKCGPointNull.y;
}

const CGSize YKCGSizeNull = {CGFLOAT_MAX, CGFLOAT_MAX};

bool YKCGSizeIsNull(CGSize size) {
  return size.width == YKCGSizeNull.width && size.height == YKCGSizeNull.height;
}

CGPathRef YKCGPathCreateLine(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2) {
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, x1, y1);
  CGPathAddLineToPoint(path, NULL, x2, y2);
  return path;
}

CGPathRef YKCGPathCreateRoundedRect(CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius) { 
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  CGFloat fw, fh;
  
  CGRect insetRect = CGRectInset(rect, strokeWidth/2.0, strokeWidth/2.0);
  CGFloat cornerWidth = cornerRadius, cornerHeight = cornerRadius;
  
  CGAffineTransform transform = CGAffineTransformIdentity;
  transform = CGAffineTransformTranslate(transform, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect));
  transform = CGAffineTransformScale(transform, cornerWidth, cornerHeight);
  
  fw = CGRectGetWidth(insetRect) / cornerWidth;
  fh = CGRectGetHeight(insetRect) / cornerHeight;
  CGPathMoveToPoint(path, &transform, fw, fh/2); 
  CGPathAddArcToPoint(path, &transform, fw, fh, fw/2, fh, 1);
  CGPathAddArcToPoint(path, &transform, 0, fh, 0, fh/2, 1);
  CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
  CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);  
  CGPathCloseSubpath(path);
  
  return path;
}

void YKCGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius) {      
  CGPathRef path = YKCGPathCreateRoundedRect(rect, strokeWidth, cornerRadius);
  CGContextAddPath(context, path);  
  CGPathRelease(path);
}

void YKCGContextDrawPath(CGContextRef context, CGPathRef path, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth) { 
  if (fillColor != NULL) CGContextSetFillColorWithColor(context, fillColor);  
  if (strokeColor != NULL) CGContextSetStrokeColorWithColor(context, strokeColor);    
  CGContextSetLineWidth(context, strokeWidth);
  CGContextAddPath(context, path);
  if (strokeColor != NULL && fillColor != NULL) CGContextDrawPath(context, kCGPathFillStroke);
  else if (strokeColor == NULL && fillColor != NULL) CGContextDrawPath(context, kCGPathFill);
  else if (strokeColor != NULL && fillColor == NULL) CGContextDrawPath(context, kCGPathStroke);
}

void YKCGContextDrawRoundedRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius) {   
  CGPathRef path = YKCGPathCreateRoundedRect(rect, strokeWidth, cornerRadius);
  YKCGContextDrawPath(context, path, fillColor, strokeColor, strokeWidth);
  CGPathRelease(path);
}

void YKCGContextAddLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2) {
  CGContextMoveToPoint(context, x, y);
  CGContextAddLineToPoint(context, x2, y2);
}

void YKCGContextDrawLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2, CGColorRef strokeColor, CGFloat strokeWidth) {
  CGContextBeginPath(context);  
  YKCGContextAddLine(context, x, y, x2, y2);
  if (strokeColor != NULL) CGContextSetStrokeColorWithColor(context, strokeColor);
  CGContextSetLineWidth(context, strokeWidth);
  CGContextStrokePath(context);   
}

void _YKCGContextDrawImage(CGContextRef context, CGImageRef image, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, 
                           CGFloat cornerRadius, BOOL scaleToAspect, BOOL fill, CGColorRef backgroundColor);

void YKCGContextDrawImage(CGContextRef context, CGImageRef image, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, 
                          BOOL scaleToAspect, CGColorRef backgroundColor) { 
  _YKCGContextDrawImage(context, image, rect, strokeColor, strokeWidth, 0.0, scaleToAspect, NO, backgroundColor);
}

void YKCGContextDrawRoundedRectImage(CGContextRef context, CGImageRef image, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, 
                                     CGFloat cornerRadius, BOOL scaleToAspect, BOOL fill, CGColorRef backgroundColor) {  
  CGContextSaveGState(context);
  _YKCGContextDrawImage(context, image, rect, strokeColor, strokeWidth, cornerRadius, scaleToAspect, fill, backgroundColor);
  CGContextRestoreGState(context);
}

void _YKCGContextDrawImage(CGContextRef context, CGImageRef image, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, 
                           CGFloat cornerRadius, BOOL scaleToAspect, BOOL fill, CGColorRef backgroundColor) {
  
  // TODO(gabe): Fails if cornerRadius = 0
  if (strokeWidth > 0 && cornerRadius > 0) {
    YKCGContextAddRoundedRect(context, rect, strokeWidth, cornerRadius);
    CGContextClip(context);
  }
  
  if (backgroundColor != NULL) {
    CGContextSetFillColorWithColor(context, backgroundColor);
    CGContextFillRect(context, rect);
  }
  
  // Reset maintainAspectRatio if image is NULL; forcing draw bounds to be same as rect
  if (image == NULL) scaleToAspect = NO;
  
  CGRect imageBounds;
  // If we are scaling image, then image bounds are rect
  // Otherwise figure out y, height (for squeezing horizontal) or x, width (for squeezing vertical)
  if (!scaleToAspect) {
    imageBounds = rect;
  } else {
    CGFloat imageHeight = (CGFloat)CGImageGetHeight(image);
    CGFloat imageWidth = (CGFloat)CGImageGetWidth(image);
    imageBounds = YKCGRectScaleAspectAndCenter(CGSizeMake(imageWidth, imageHeight), rect.size, fill);
  }
  
  if (image != NULL) {
    CGContextSaveGState(context);
    // Flip coordinate system, otherwise image will be drawn upside down  
    CGContextTranslateCTM (context, rect.origin.x, imageBounds.size.height + rect.origin.y);
    CGContextScaleCTM (context, 1.0, -1.0);   
    imageBounds.origin.y *= -1; // Going opposite direction
    CGContextDrawImage(context, imageBounds, image);
    CGContextRestoreGState(context);
  }
  
  if (strokeColor != NULL && strokeWidth > 0 && cornerRadius > 0)
    YKCGContextDrawRoundedRect(context, rect, NULL, strokeColor, strokeWidth, cornerRadius);
}

CGRect YKCGRectScaleAspectAndCenter(CGSize size, CGSize inSize, BOOL fill) {
  if (YKCGSizeIsEmpty(size)) return CGRectZero;
  
  CGRect rect;
  CGFloat widthScaleRatio = inSize.width / size.width;
  CGFloat heightScaleRatio = inSize.height / size.height;
  
  if (widthScaleRatio < heightScaleRatio) {
    if (fill) {
      CGFloat height = inSize.height;
      CGFloat width = roundf(size.width * heightScaleRatio);
      CGFloat x = roundf((inSize.width - width) / 2.0);
      rect = CGRectMake(x, 0, width, height);
    } else {    
      CGFloat height = roundf(size.height * widthScaleRatio);
      CGFloat y = roundf((inSize.height / 2.0) - (height / 2.0));
      rect = CGRectMake(0, y, inSize.width, height);
    }
  } else {
    if (fill) {
      CGFloat width = inSize.width;
      CGFloat height = roundf(size.height * widthScaleRatio);
      CGFloat y = roundf((inSize.height - height) / 2.0);
      rect = CGRectMake(0, y, width, height);
    } else { 
      CGFloat width = roundf(size.width * heightScaleRatio);
      CGFloat x = roundf((inSize.width / 2.0) - (width / 2.0));
      rect = CGRectMake(x, 0, width, inSize.height);
    }
  }
  return rect;
}

BOOL YKCGPointIsZero(CGPoint p) {
  return (YKIsEqualWithAccuracy(p.x, 0, 0.0001) && YKIsEqualWithAccuracy(p.y, 0, 0.0001));
}

BOOL YKCGPointIsEqual(CGPoint p1, CGPoint p2) {
  return (YKIsEqualWithAccuracy(p1.x, p2.x, 0.0001) && YKIsEqualWithAccuracy(p1.y, p2.y, 0.0001));
}

BOOL YKCGRectIsEqual(CGRect rect1, CGRect rect2) {
  return (YKCGPointIsEqual(rect1.origin, rect2.origin) && YKCGSizeIsEqual(rect1.size, rect2.size));  
}

CGPoint YKCGPointToCenterY(CGSize size, CGSize inSize) {
  CGPoint p = CGPointMake(0, roundf((inSize.height - size.height) / 2.0));
  if (p.y < 0) p.y = 0;
  return p;
}

CGPoint YKCGPointToCenter(CGSize size, CGSize inSize) {
  // We round otherwise views will anti-alias
  CGPoint p = CGPointMake(roundf((inSize.width - size.width) / 2.0), roundf((inSize.height - size.height) / 2.0));
  // Allowing negative values here allows us to center a larger view on a smaller view.
  // Though set to 0 if inSize.height was 0
  if (inSize.height == 0) p.y = 0;
  return p;
}

CGPoint YKCGPointToRight(CGSize size, CGSize inSize) {
  CGPoint p = CGPointMake(inSize.width - size.width, roundf(inSize.height / 2.0 - size.height / 2.0));
  if (p.x < 0) p.x = 0;
  if (p.y < 0) p.y = 0;
  return p;
}

BOOL YKCGSizeIsEqual(CGSize size1, CGSize size2) {
  return (YKIsEqualWithAccuracy(size1.height, size2.height, 0.0001) && YKIsEqualWithAccuracy(size1.width, size2.width, 0.0001));
}

BOOL YKCGSizeIsZero(CGSize size) {
  return (size.width == 0 && size.height == 0);
}

BOOL YKCGSizeIsEmpty(CGSize size) {
  return (YKIsEqualWithAccuracy(size.height, 0, 0.0001) && YKIsEqualWithAccuracy(size.width, 0, 0.0001));
}

CGRect YKCGRectToCenter(CGSize size, CGSize inSize) {
  CGPoint p = YKCGPointToCenter(size, inSize);
  return CGRectMake(p.x, p.y, size.width, size.height);
}

CGRect YKCGRectToCenterInRect(CGSize size, CGRect inRect) {
  CGPoint p = YKCGPointToCenter(size, inRect.size);
  return CGRectMake(p.x + inRect.origin.x, p.y + inRect.origin.y, size.width, size.height);
}

CGRect YKCGRectToCenterY(CGRect rect, CGRect inRect) {
  CGPoint centeredPoint = YKCGPointToCenter(rect.size, inRect.size);
  return YKCGRectSetY(rect, centeredPoint.y);
}

CGFloat YKCGFloatToCenter(CGFloat length, CGFloat inLength, CGFloat min) {
  CGFloat pos = roundf(inLength / 2.0 - length / 2.0);
  if (pos < min) pos = min;
  return pos;
}

CGRect YKCGRectAdd(CGRect rect1, CGRect rect2) {
  return CGRectMake(rect1.origin.x + rect2.origin.x, rect1.origin.y + rect2.origin.y, rect1.size.width + rect2.size.width, rect1.size.height + rect2.size.height);
}

CGRect YKCGRectRightAlign(CGFloat y, CGFloat width, CGFloat inWidth, CGFloat maxWidth, CGFloat padRight, CGFloat height) {
  if (width > maxWidth) width = maxWidth;
  CGFloat x = (inWidth - width - padRight);
  return CGRectMake(x, y, width, height);
}

CGRect YKCGRectZeroOrigin(CGRect rect) {
  return CGRectMake(0, 0, rect.size.width, rect.size.height);
}

CGRect YKCGRectSetSize(CGRect rect, CGSize size) {
  rect.size = size;
  return rect;
}

CGRect YKCGRectSetHeight(CGRect rect, CGFloat height) {
  rect.size.height = height;
  return rect;  
}

CGRect YKCGRectAddHeight(CGRect rect, CGFloat add) {
  rect.size.height += add;
  return rect;  
}

CGRect YKCGRectAddX(CGRect rect, CGFloat add) {
  rect.origin.x += add;
  return rect;  
}

CGRect YKCGRectAddY(CGRect rect, CGFloat add) {
  rect.origin.y += add;
  return rect;  
}

CGRect YKCGRectSetWidth(CGRect rect, CGFloat width) {
  rect.size.width = width;
  return rect;  
}

CGRect YKCGRectSetOrigin(CGRect rect, CGFloat x, CGFloat y) {
  rect.origin = CGPointMake(x, y);
  return rect;
}

CGRect YKCGRectSetX(CGRect rect, CGFloat x) {
  rect.origin.x = x;
  return rect;
}

CGRect YKCGRectSetY(CGRect rect, CGFloat y) {
  rect.origin.y = y;
  return rect;
}

CGRect YKCGRectSetOriginPoint(CGRect rect, CGPoint p) {
  rect.origin = p;
  return rect;
}

CGRect YKCGRectOriginSize(CGPoint origin, CGSize size) {
  CGRect rect;
  rect.origin = origin;
  rect.size = size;
  return rect;
}

CGRect YKCGRectAddPoint(CGRect rect, CGPoint p) {
  rect.origin.x += p.x;
  rect.origin.y += p.y;
  return rect;
}

CGPoint YKCGPointBottomRight(CGRect rect) {
  return CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
}

CGFloat YKCGDistanceBetween(CGPoint pointA, CGPoint pointB) {
  CGFloat dx = pointB.x - pointA.x;
  CGFloat dy = pointB.y - pointA.y;
  return sqrt(dx*dx + dy*dy);
}

CGRect YKCGRectWithInsets(CGSize size, UIEdgeInsets insets) {
  CGRect rect = CGRectZero;
  rect.origin.x = insets.left;
  rect.origin.y = insets.top;
  rect.size.width = size.width - insets.left - insets.right;
  rect.size.height = size.height - insets.top - insets.bottom;
  return rect;
}

#pragma mark Border Styles

void YKCGContextAddStyledRect(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius) {  
  CGPathRef path = YKCGPathCreateStyledRect(rect, style, strokeWidth, alternateStrokeWidth, cornerRadius);
  CGContextAddPath(context, path);  
  CGPathRelease(path);
}

CGPathRef YKCGPathCreateStyledRect(CGRect rect, YKUIBorderStyle style, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius) {  
  
  CGFloat fw, fh;
  CGFloat cornerWidth = cornerRadius, cornerHeight = cornerRadius;  
  
  if (style == YKUIBorderStyleRounded) {
    assert(cornerRadius > 0);
    return YKCGPathCreateRoundedRect(rect, strokeWidth, cornerRadius);
  }
  
  CGFloat strokeInset = strokeWidth/2.0;
  CGFloat alternateStrokeInset = alternateStrokeWidth/2.0;
  
  // Need to adjust path rect to inset (since the stroke is drawn from the middle of the path)
  CGRect insetBounds;
  switch(style) {
    case YKUIBorderStyleRoundedBottomWithAlternateTop:
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y + alternateStrokeInset, rect.size.width - (strokeInset * 2), rect.size.height - alternateStrokeInset - strokeInset);
      break;
      
    case YKUIBorderStyleLeftRightWithAlternateTop:
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y + alternateStrokeInset, rect.size.width - (strokeInset * 2), rect.size.height - alternateStrokeInset);
      break;
      
    case YKUIBorderStyleRoundedTop:
      // Inset stroke width except for bottom border
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y + strokeInset, rect.size.width - (strokeInset * 2), rect.size.height - strokeInset);
      break;
      
    case YKUIBorderStyleTop:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y + strokeInset, rect.size.width, rect.size.height - strokeInset);
      break;
      
    case YKUIBorderStyleTopBottom:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y + strokeInset, rect.size.width, rect.size.height - (strokeInset * 2));
      break;
      
    case YKUIBorderStyleBottom:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y + strokeInset, rect.size.width, rect.size.height - strokeInset);
      break;
      
    case YKUIBorderStyleNormal:
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y + strokeInset, rect.size.width - (strokeInset * 2), rect.size.height - (strokeInset * 2));
      break;
      
    default:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y, 0, 0);
      break;
  }
  rect = insetBounds;
  
  CGAffineTransform transform = CGAffineTransformIdentity;
  transform = CGAffineTransformTranslate(transform, CGRectGetMinX(rect), CGRectGetMinY(rect));
  if (cornerWidth > 0 && cornerHeight > 0) {
    transform = CGAffineTransformScale(transform, cornerWidth, cornerHeight);
    fw = CGRectGetWidth(rect) / cornerWidth;
    fh = CGRectGetHeight(rect) / cornerHeight;
  } else {
    fw = CGRectGetWidth(rect);
    fh = CGRectGetHeight(rect);
  }
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  switch(style) {
    case YKUIBorderStyleRoundedBottomWithAlternateTop:
      CGPathMoveToPoint(path, &transform, fw, 0); 
      CGPathAddLineToPoint(path, &transform, fw, fh/2);
      CGPathAddArcToPoint(path, &transform, fw, fh, fw/2, fh, 1);
      CGPathAddArcToPoint(path, &transform, 0, fh, 0, fh/2, 1);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      CGPathMoveToPoint(path, &transform, fw, 0); // Don't draw top border
      break;
      
    case YKUIBorderStyleRoundedTop:
      CGPathMoveToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh/2);
      CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
      CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);      
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathMoveToPoint(path, &transform, 0, fh); // Don't draw bottom border
      break;
      
    case YKUIBorderStyleTop:
      CGPathMoveToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      break;
      
    case YKUIBorderStyleBottom:
      CGPathMoveToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
    case YKUIBorderStyleTopBottom:
      CGPathMoveToPoint(path, &transform, 0, 0);
      CGPathAddLineToPoint(path, &transform, fw, 0);
      CGPathMoveToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
    case YKUIBorderStyleLeftRightWithAlternateTop:
      // Go +/- 2 in order to clip the top and bottom border; Only draw left, right border
      CGPathMoveToPoint(path, &transform, 0, fh + 2);
      CGPathAddLineToPoint(path, &transform, 0, -2);
      CGPathAddLineToPoint(path, &transform, fw, -2);
      CGPathAddLineToPoint(path, &transform, fw, fh + 2);
      CGPathAddLineToPoint(path, &transform, 0, fh + 2);
      break;
      
    case YKUIBorderStyleNormal:
      CGPathMoveToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      CGPathAddLineToPoint(path, &transform, fw, 0);      
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
      /*
       case YKUIBorderStyleTopBottomRight:
       CGPathMoveToPoint(path, &transform, -2, fh);
       CGPathAddLineToPoint(path, &transform, -2, 0);
       CGPathAddLineToPoint(path, &transform, fw, 0);      
       CGPathAddLineToPoint(path, &transform, fw, fh);
       CGPathAddLineToPoint(path, &transform, -2, fh);
       break;
       */
    default:
      break;
  }
  
  return path;
}

BOOL YKCGContextAddAlternateBorderToPath(CGContextRef context, CGRect rect, YKUIBorderStyle style) {
  // Skip styles that don't have alternate border path
  if (style != YKUIBorderStyleRoundedBottomWithAlternateTop &&
      style != YKUIBorderStyleLeftRightWithAlternateTop) {
    return NO;
  }
  
  CGFloat cornerWidth = 10, cornerHeight = 10;
  
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
  CGContextScaleCTM (context, cornerWidth, cornerHeight);
  CGFloat fw = CGRectGetWidth(rect) / cornerWidth;
  
  CGContextMoveToPoint(context, 0, 0);
  CGContextAddLineToPoint(context, fw, 0);
  CGContextRestoreGState(context);
  return YES;
}

void _YKCGContextDrawStyledRect(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius) {
  CGContextSetLineWidth(context, strokeWidth);
  
  YKCGContextAddStyledRect(context, rect, style, strokeWidth, 0, cornerRadius); 
  
  if (strokeColor != NULL) CGContextSetStrokeColorWithColor(context, strokeColor);  
  if (fillColor != NULL) CGContextSetFillColorWithColor(context, fillColor);
  
  if (fillColor != NULL && strokeColor != NULL) {     
    CGContextDrawPath(context, kCGPathFillStroke);
  } else if (strokeColor != NULL) {
    CGContextDrawPath(context, kCGPathStroke);
  } else if (fillColor != NULL) {
    CGContextDrawPath(context, kCGPathFill);
  } 
}

void YKCGContextDrawBorder(CGContextRef context, CGRect rect, YKUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat alternateStrokeWidth, CGFloat cornerRadius) {
  
  _YKCGContextDrawStyledRect(context, rect, style, fillColor, strokeColor, strokeWidth, cornerRadius);
  
  if (alternateStrokeWidth > 0) {
    CGContextSetLineWidth(context, alternateStrokeWidth);
    CGContextBeginPath(context);
    if (YKCGContextAddAlternateBorderToPath(context, rect, style))
      CGContextDrawPath(context, kCGPathStroke);
  }
}

void YKCGContextDrawRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth) {
  _YKCGContextDrawStyledRect(context, rect, YKUIBorderStyleNormal, fillColor, strokeColor, strokeWidth, 1);
}

#pragma mark Colors

void YKCGColorGetComponents(CGColorRef color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
  const CGFloat *components = CGColorGetComponents(color);
  *red = *green = *blue = 0.0;
  *alpha = 1.0;
  size_t num = CGColorGetNumberOfComponents(color);
  if (num <= 2) {
    *red = components[0];
    *green = components[0];
    *blue = components[0];
    if (num == 2) *alpha = components[1];
  } else if (num >= 3) {
    *red = components[0];
    *green = components[1];
    *blue = components[2];
    if (num >= 4) *alpha = components[3];
  }
}

#pragma mark Shading

//
// Portions adapted from:
// http://wilshipley.com/blog/2005/07/pimp-my-code-part-3-gradient.html
//


// For shading
typedef struct {
  CGFloat red1, green1, blue1, alpha1;
  CGFloat red2, green2, blue2, alpha2;
  CGFloat red3, green3, blue3, alpha3;
  CGFloat red4, green4, blue4, alpha4;
} _YKUIColors;

void _horizontalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out, BOOL reverse) {
  _YKUIColors *colors = (_YKUIColors *)info;
  
  float v = *in;
  if ((!reverse && v < 0.5) || (reverse && v >= 0.5)) {
    v = (v * 2.0) * 0.3 + 0.6222;
    *out++ = 1.0 - v + colors->red1 * v;
    *out++ = 1.0 - v + colors->green1 * v;
    *out++ = 1.0 - v + colors->blue1 * v;
    *out++ = 1.0 - v + colors->alpha1 * v;
  } else {
    *out++ = colors->red2;
    *out++ = colors->green2;
    *out++ = colors->blue2;
    *out++ = colors->alpha2;
  }
}

void _metalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out) {
  _YKUIColors *colors = (_YKUIColors *)info;
  
  float v = *in;
  if (v < 0.5) {
    v = (v * 2.0);
    *out++ = (v * colors->red2) + (1 - v) * colors->red1;
    *out++ = (v * colors->green2) + (1 - v) * colors->green1;
    *out++ = (v * colors->blue2) + (1 - v) * colors->blue1;
    *out++ = (v * colors->alpha2) + (1 - v) * colors->alpha1;
  } else {
    v = ((v - 0.5) * 2.0);
    *out++ = (v * colors->red4) + (1 - v) * colors->red3;
    *out++ = (v * colors->green4) + (1 - v) * colors->green3;
    *out++ = (v * colors->blue4) + (1 - v) * colors->blue3;
    *out++ = (v * colors->alpha4) + (1 - v) * colors->alpha3;
  }
}

void _horizontalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _horizontalEdgeColorBlendFunctionImpl(info, in, out, NO);
}

void _horizontalReverseEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _horizontalEdgeColorBlendFunctionImpl(info, in, out, YES);
}

void _metalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _metalEdgeColorBlendFunctionImpl(info, in, out);
}

void _linearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _YKUIColors *colors = info;
  
  out[0] = (1.0 - *in) * colors->red1 + *in * colors->red2;
  out[1] = (1.0 - *in) * colors->green1 + *in * colors->green2;
  out[2] = (1.0 - *in) * colors->blue1 + *in * colors->blue2;
  out[3] = (1.0 - *in) * colors->alpha1 + *in * colors->alpha2;
}

void _exponentialColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _YKUIColors *colors = info;
  float amount1 = (1.0 - powf(*in, 2));
  float amount2 = (1.0 - amount1);
  
  out[0] = (amount1 * colors->red1) + (amount2 * colors->red2);
  out[1] = (amount1 * colors->green1) + (amount2 * colors->green2);
  out[2] = (amount1 * colors->blue1) + (amount2 * colors->blue2);
  out[3] = (amount1 * colors->alpha1) + (amount2 * colors->alpha2);
}

void _colorReleaseInfoFunction(void *info) {
  free(info);
}

static const CGFunctionCallbacks linearFunctionCallbacks = {0, &_linearColorBlendFunction, &_colorReleaseInfoFunction};
static const CGFunctionCallbacks horizontalEdgeFunctionCallbacks = {0, &_horizontalEdgeColorBlendFunction, &_colorReleaseInfoFunction};
static const CGFunctionCallbacks horizontalReverseEdgeFunctionCallbacks = {0, &_horizontalReverseEdgeColorBlendFunction, &_colorReleaseInfoFunction};
static const CGFunctionCallbacks exponentialFunctionCallbacks = {0, &_exponentialColorBlendFunction, &_colorReleaseInfoFunction};
static const CGFunctionCallbacks metalEdgeFunctionCallbacks = {0, &_metalEdgeColorBlendFunction, &_colorReleaseInfoFunction};

void YKCGContextDrawShadingWithHeight(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGFloat height, YKUIShadingType shadingType) {
  YKCGContextDrawShading(context, color, color2, color3, color4, CGPointMake(0, 0), CGPointMake(0, height), shadingType, YES, YES);
}

void YKCGContextDrawShading(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGPoint start, CGPoint end, YKUIShadingType shadingType, 
                            BOOL extendStart, BOOL extendEnd) {
  
  const CGFunctionCallbacks *callbacks;
  
  switch (shadingType) {
    case YKUIShadingTypeHorizontalEdge:
      callbacks = &horizontalEdgeFunctionCallbacks;
      break;      
    case YKUIShadingTypeHorizontalReverseEdge:
      callbacks = &horizontalReverseEdgeFunctionCallbacks;
      break;
    case YKUIShadingTypeLinear:
      callbacks = &linearFunctionCallbacks;
      break;
    case YKUIShadingTypeExponential:
      callbacks = &exponentialFunctionCallbacks;
      break;
    case YKUIShadingTypeMetalEdge:
      callbacks = &metalEdgeFunctionCallbacks;
      break;
    default:
      return;
  }  
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  _YKUIColors *colors = malloc(sizeof(_YKUIColors));
  
  YKCGColorGetComponents(color, &colors->red1, &colors->green1, &colors->blue1, &colors->alpha1);
  YKCGColorGetComponents((color2 != NULL ? color2 : color), &colors->red2, &colors->green2, &colors->blue2, &colors->alpha2);
  if (color3 != NULL) {
    YKCGColorGetComponents(color3, &colors->red3, &colors->green3, &colors->blue3, &colors->alpha3);
  }
  if (color4 != NULL) {
    YKCGColorGetComponents(color4, &colors->red4, &colors->green4, &colors->blue4, &colors->alpha4);
  }
  
  static const CGFloat domainAndRange[8] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
  
  CGFunctionRef blendFunctionRef = CGFunctionCreate(colors, 1, domainAndRange, 4, domainAndRange, callbacks);
  CGShadingRef shading = CGShadingCreateAxial(colorSpace, start, end, blendFunctionRef, extendStart, extendEnd);
  CGContextDrawShading(context, shading);
  CGShadingRelease(shading);
  CGFunctionRelease(blendFunctionRef);
  CGColorSpaceRelease(colorSpace);
}

// From Three20: UIImageAdditions#convertRect
CGRect YKCGRectConvert(CGRect rect, CGSize size, UIViewContentMode contentMode) {
  if (size.width != rect.size.width || size.height != rect.size.height) {
    if (contentMode == UIViewContentModeLeft) {
      return CGRectMake(rect.origin.x,
                        rect.origin.y + floor(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeRight) {
      return CGRectMake(rect.origin.x + (rect.size.width - size.width),
                        rect.origin.y + floor(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeTop) {
      return CGRectMake(rect.origin.x + floor(rect.size.width/2 - size.width/2),
                        rect.origin.y,
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeBottom) {
      return CGRectMake(rect.origin.x + floor(rect.size.width/2 - size.width/2),
                        rect.origin.y + floor(rect.size.height - size.height),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeCenter) {
      return CGRectMake(rect.origin.x + floor(rect.size.width/2 - size.width/2),
                        rect.origin.y + floor(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeBottomLeft) {
      return CGRectMake(rect.origin.x,
                        rect.origin.y + floor(rect.size.height - size.height),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeBottomRight) {
      return CGRectMake(rect.origin.x + (rect.size.width - size.width),
                        rect.origin.y + (rect.size.height - size.height),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeTopLeft) {
      return CGRectMake(rect.origin.x,
                        rect.origin.y,                        
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeTopRight) {
      return CGRectMake(rect.origin.x + (rect.size.width - size.width),
                        rect.origin.y,
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeScaleAspectFill) {
      CGSize imageSize = size;
      if (imageSize.height < imageSize.width) {
        imageSize.width = floorf((imageSize.width/imageSize.height) * rect.size.height);
        imageSize.height = rect.size.height;
      } else {
        imageSize.height = floorf((imageSize.height/imageSize.width) * rect.size.width);
        imageSize.width = rect.size.width;
      }
      return CGRectMake(rect.origin.x + floorf(rect.size.width/2 - imageSize.width/2),
                        rect.origin.y + floorf(rect.size.height/2 - imageSize.height/2),
                        imageSize.width, imageSize.height);
    } else if (contentMode == UIViewContentModeScaleAspectFit) {
      if (size.height < size.width) {
        size.height = floorf((size.height/size.width) * rect.size.width);
        size.width = rect.size.width;
      } else {
        size.width = floorf((size.width/size.height) * rect.size.height);
        size.height = rect.size.height;
      }
      return CGRectMake(rect.origin.x + floorf(rect.size.width/2 - size.width/2),
                        rect.origin.y + floorf(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    }
  }
  return rect;
}


NSString *YKNSStringFromUIViewContentMode(UIViewContentMode contentMode) {
  switch (contentMode) {
    case UIViewContentModeScaleToFill: return @"UIViewContentModeScaleToFill";
    case UIViewContentModeScaleAspectFit: return @"UIViewContentModeScaleAspectFit";
    case UIViewContentModeScaleAspectFill: return @"UIViewContentModeScaleAspectFill";
    case UIViewContentModeRedraw: return @"UIViewContentModeRedraw";
    case UIViewContentModeCenter: return @"UIViewContentModeCenter";
    case UIViewContentModeTop: return @"UIViewContentModeTop";
    case UIViewContentModeBottom: return @"UIViewContentModeBottom";
    case UIViewContentModeLeft: return @"UIViewContentModeLeft";
    case UIViewContentModeRight: return @"UIViewContentModeRight";
    case UIViewContentModeTopLeft: return @"UIViewContentModeTopLeft";
    case UIViewContentModeTopRight: return @"UIViewContentModeTopRight";
    case UIViewContentModeBottomLeft: return @"UIViewContentModeBottomLeft";
    case UIViewContentModeBottomRight: return @"UIViewContentModeBottomRight";
  }
  return @"Unknown content mode";
}

CGRect YKCGRectScaleFromCenter(CGRect rect, CGFloat scale) {
  CGSize newRectSize = CGSizeMake(rect.size.width * scale, rect.size.height * scale);
  return YKCGRectToCenterInRect(newRectSize, rect);
}

// Linear gradient function from Ray Wenderlich
// http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
void YKCGContextDrawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor) {
  CGColorSpaceRef startColorSpace = CGColorGetColorSpace(startColor);
  CGColorSpaceRef endColorSpace = CGColorGetColorSpace(endColor);
  // Cannot draw a gradient if the color spaces are not the same
  if (startColorSpace != endColorSpace) {
    return;
  }
  
  CGFloat locations[] = { 0.0, 1.0 };
  
  NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
  
  CGGradientRef gradient = CGGradientCreateWithColors(startColorSpace, (CFArrayRef) colors, locations);
  
  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
  
  CGContextSaveGState(context);
  CGContextAddRect(context, rect);
  CGContextClip(context);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextRestoreGState(context);
  
  CGGradientRelease(gradient);
}

UIImage *YKCreateVerticalGradientImage(CGFloat height, CGColorRef topColor, CGColorRef bottomColor) {
  
  // If there are performance issues with tiling a lot of skinny images,
  // maybe this could be increased or made into a parameter
  CGFloat width = 1;
  
  // Create new offscreen context with desired size
  UIGraphicsBeginImageContext(CGSizeMake(width, height));
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  YKCGContextDrawRect(context, CGRectMake(0, 0, width, height), [UIColor whiteColor].CGColor, [UIColor whiteColor].CGColor, 0.0);
  YKCGContextDrawLinearGradient(context, CGRectMake(0, 0, width, height), topColor, bottomColor);
  
  // assign context to UIImage
  UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
  
  // end context
  UIGraphicsEndImageContext();
  
  return outputImg;
}


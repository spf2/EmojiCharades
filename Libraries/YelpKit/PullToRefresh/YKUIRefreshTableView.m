//
//  YKUIRefreshTableView.m
//  YelpKit
//
//  Created by Gabriel Handford on 8/23/11.
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

#import "YKUIRefreshTableView.h"

@implementation YKUIRefreshTableView

@synthesize refreshHeaderView=_refreshHeaderView, refreshDelegate=_refreshDelegate;

- (void)dealloc {
  [_refreshHeaderView release];
  [super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _refreshHeaderView.frame = CGRectMake(0, 0 - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setRefreshing:(BOOL)refreshing {
  // Ensure refresh header is loading;
  // If we are momentary then ensure we aren't expanded
  [_refreshHeaderView setState:(refreshing ? YKUIPullRefreshLoading : YKUIPullRefreshNormal)];
  if (_refreshHeaderView.momentary) {
    [self expandRefreshHeaderView:NO];
  } else {    
    [self expandRefreshHeaderView:refreshing];
  }
}

- (void)setRefreshHeaderEnabled:(BOOL)enabled {
  if (enabled && !_refreshHeaderView) {
    _refreshHeaderView = [[YKUIRefreshTableHeaderView alloc] init];
    [self addSubview:_refreshHeaderView];
    [self sendSubviewToBack:_refreshHeaderView];
    self.showsVerticalScrollIndicator = YES;    
  } else if (!enabled) {
    [_refreshHeaderView removeFromSuperview];
    [_refreshHeaderView release];
    _refreshHeaderView = nil;
  }
  [self setNeedsLayout];
}

- (BOOL)isRefreshHeaderEnabled {
  return !!_refreshHeaderView;
}

- (void)expandRefreshHeaderView:(BOOL)expand {
  if (expand) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.contentInset = UIEdgeInsetsMake(_refreshHeaderView.pullHeight, 0, 0, 0);
    [UIView commitAnimations];  
  } else {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];  
  }
}

#pragma mark Delegates (UIScrollView)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_refreshHeaderView && scrollView.isDragging) {    
    if (_refreshHeaderView.state == YKUIPullRefreshPulling && scrollView.contentOffset.y > -(_refreshHeaderView.pullHeight + 5) && scrollView.contentOffset.y < 0) {
      [_refreshHeaderView setState:YKUIPullRefreshNormal];
    } else if (_refreshHeaderView.state == YKUIPullRefreshNormal && scrollView.contentOffset.y < -(_refreshHeaderView.pullHeight + 5)) {
      [_refreshHeaderView setState:YKUIPullRefreshPulling];
    }    
  }
  [_refreshHeaderView setPullAmount:-scrollView.contentOffset.y];
  
  // Fix issue where header doesn't scroll right while into pull to refresh
  if (!_refreshHeaderView.momentary && _refreshHeaderView.state == YKUIPullRefreshLoading) {
    if (scrollView.contentOffset.y >= 0) {
      scrollView.contentInset = UIEdgeInsetsZero;
    } else {
      scrollView.contentInset = UIEdgeInsetsMake(MIN(-scrollView.contentOffset.y, _refreshHeaderView.pullHeight), 0, 0, 0);
    }
  }  
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {  
  if (_refreshHeaderView && scrollView.contentOffset.y <= -(_refreshHeaderView.pullHeight + 5) &&  _refreshHeaderView.state != YKUIPullRefreshLoading) {
    [_refreshDelegate refreshScrollViewShouldRefresh:self];
  } else {
    [_refreshHeaderView setPullAmount:0];
  }
}

@end

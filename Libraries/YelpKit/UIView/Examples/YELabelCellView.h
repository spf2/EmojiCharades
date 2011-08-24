//
//  YELabelCellView.h
//  YelpKit
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011 Yelp. All rights reserved.
//

#import "YKUIView.h"

@interface YELabelCellView : YKUIView {
  UILabel *_nameLabel;
  UILabel *_statusLabel;  
}

- (void)setName:(NSString *)name status:(NSString *)status;

@end

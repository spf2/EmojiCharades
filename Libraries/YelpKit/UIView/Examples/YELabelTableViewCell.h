//
//  YELabelTableViewCell.h
//  YelpKit
//
//  Created by Gabriel Handford on 8/23/11.
//  Copyright 2011 Yelp. All rights reserved.
//

#import "YELabelCellView.h"

@interface YELabelTableViewCell : UITableViewCell {
  YELabelCellView *_cellView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (readonly, nonatomic) YELabelCellView *cellView;

@end
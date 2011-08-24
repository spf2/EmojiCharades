//
//  ECGameCellView.h
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YKUIView.h"
#import "YKUIImageView.h"

@interface ECGameCellView : YKUIView {
  YKUIImageView *_userImageView;
  UILabel *_userNameLabel;
  UILabel *_timeAgoLabel;
  UILabel *_hintLabel;
  UILabel *_statusLabel;
}

- (void)setUserName:(NSString *)userName userImageURLString:(NSString *)userImageURLString lastModifiedDate:(NSDate *)lastModifiedDate hint:(NSString *)hint status:(NSString *)status;

@end


@interface ECGameTableViewCell : UITableViewCell {
  ECGameCellView *_gameCellView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (readonly, nonatomic) ECGameCellView *gameCellView;

@end
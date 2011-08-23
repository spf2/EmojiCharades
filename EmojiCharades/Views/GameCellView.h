//
//  GameCellView.h
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YKUIView.h"

@interface GameCellView : YKUIView {
  UIImageView *_userImageView;
  UILabel *_userNameLabel;
  UILabel *_timeAgoLabel;
  UILabel *_hintLabel;
  UILabel *_statusLabel;  
}

- (void)setUserName:(NSString *)userName lastModifiedDate:(NSDate *)lastModifiedDate hint:(NSString *)hint status:(NSString *)status;

@end


@interface GameTableViewCell : UITableViewCell {
  GameCellView *_gameCellView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (readonly, nonatomic) GameCellView *gameCellView;

@end
//
//  ECTurnCellView.h
//  EmojiCharades
//
//  Created by Rowan on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YKUIView.h"
#import "YKUIImageView.h"

@interface ECTurnCellView : YKUIView {
    YKUIImageView *_userImageView;
    UILabel *_userNameLabel;
    UILabel *_timeAgoLabel;
    UILabel *_textLabel;
}

- (void)setUserName:(NSString *)userName userImageURLString:(NSString *)userImageURLString lastModifiedDate:(NSDate *)lastModifiedDate text:(NSString *)text status:(int)status;

@end

@interface ECTurnTableViewCell : UITableViewCell {
    ECTurnCellView *_turnCellView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (readonly, nonatomic) ECTurnCellView *turnCellView;

@end

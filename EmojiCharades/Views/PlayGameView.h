//
//  PlayGameView.h
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/15/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayGameView : UIView { 
  UILabel *_hintLabel;
  UILabel *_metadataLabel;
  UIScrollView *_turnTableScrollView;
}

@property (nonatomic, retain) IBOutlet UILabel *hintLabel;
@property (nonatomic, retain) IBOutlet UILabel *metadataLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *turnTableScrollView;

@end

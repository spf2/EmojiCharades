//
//  PlayGameController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECGame.h"

@protocol PlayGameDelegate
- (void) gamePlayedOk:(ECGame *)game;
@end

@interface PlayGameController : UIViewController<RKObjectLoaderDelegate> {
    UILabel *hintLabel;
    UILabel *metadataLabel;
    UITableView *turnTableView;
    UITextField *guessTextField;
    UIBarButtonItem *guessButton;
    ECGame *game;
}

@property (nonatomic, retain) IBOutlet UILabel *hintLabel;
@property (nonatomic, retain) IBOutlet UILabel *metadataLabel;
@property (nonatomic, retain) IBOutlet UITableView *turnTableView;
@property (nonatomic, retain) IBOutlet UITextField *guessTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *guessButton;
@property (nonatomic, retain) ECGame *game;

@end

//
//  ResultController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECTurn.h"

@protocol ResultControllerDelegate <NSObject>
- (void)resultOk:(ECTurn *)turn;
@end

@interface ResultController : UIViewController<RKObjectLoaderDelegate>

@property (nonatomic, retain) IBOutlet UILabel *hintTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *hintMetadataLabel;
@property (nonatomic, retain) IBOutlet UILabel *guessTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *guessMetadataLabel;
@property (nonatomic, retain) IBOutlet UIButton *rightButton;
@property (nonatomic, retain) IBOutlet UIButton *wrongButton;
@property (nonatomic, retain) ECTurn *turn;
@property (nonatomic, retain) id<ResultControllerDelegate> delegate;

- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)wrongButtonPressed:(id)sender;

@end

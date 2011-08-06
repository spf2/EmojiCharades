//
//  SetupViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestKit/RestKit.h"
#import "ECUser.h"


@protocol SetupViewDelegate
- (void) userSetupOk:(ECUser *)user;
@end


@interface SetupViewController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate> {
    id<SetupViewDelegate> delegate;
    UIBarButtonItem *doneButton;
    UILabel *warningLabel;
}

- (IBAction)userNameDone:(id)sender;
- (void)showWarning:(NSString *)message;
- (IBAction)userNameEditingDidBegin:(id)sender;

@property (nonatomic, retain) id<SetupViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UILabel *warningLabel;

@end


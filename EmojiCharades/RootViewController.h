//
//  RootViewController.h
//  EmojiCharades
//
//  Created by Steve Farrell on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShowGamesController;

@interface RootViewController : UIViewController {
    UIBarButtonItem *playButtonItem;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *playButtonItem;

@end

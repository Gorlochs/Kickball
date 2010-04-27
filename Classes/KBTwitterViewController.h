//
//  KBTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "XAuthTwitterEngine.h"
#import "KBTwitterManager.h"


@interface KBTwitterViewController : KBBaseViewController {
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *mentionsButton;
    IBOutlet UIButton *directMessageButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *centerHeaderButton;
    
    XAuthTwitterEngine *twitterEngine;
}

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction) flipBetweenMapAndList;
- (IBAction) showMentions;
- (IBAction) showDirectMessages;
- (IBAction) showUserTimeline;
- (IBAction) showSearch;

@end

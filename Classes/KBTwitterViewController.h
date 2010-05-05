//
//  KBTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"
#import "XAuthTwitterEngine.h"
#import "KBTwitterManager.h"


@interface KBTwitterViewController : KBFoursquareViewController {
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *mentionsButton;
    IBOutlet UIButton *directMessageButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *twitterCenterHeaderButton;
    
    XAuthTwitterEngine *twitterEngine;
}

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction) flipBetweenMapAndList;
- (IBAction) showMentions;
- (IBAction) showDirectMessages;
- (IBAction) showUserTimeline;
- (IBAction) showSearch;

@end

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

@class KBCreateTweetViewController, KBGeoTweetMapViewController;

@interface KBTwitterViewController : KBFoursquareViewController {
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *mentionsButton;
    IBOutlet UIButton *directMessageButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *twitterCenterHeaderButton;
    
    XAuthTwitterEngine *twitterEngine;
    KBCreateTweetViewController *tweetController;
    KBGeoTweetMapViewController *mapController;
}

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction) flipBetweenMapAndList;
- (IBAction) showMentions;
- (IBAction) showDirectMessages;
- (IBAction) showUserTimeline;
- (IBAction) showSearch;
- (IBAction) openTweetModalView;

@end

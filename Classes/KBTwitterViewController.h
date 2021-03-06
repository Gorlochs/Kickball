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

@class KBTwitterLoginView;
@interface KBTwitterViewController : KBFoursquareViewController <KBTwitterManagerDelegate> {
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *mentionsButton;
    IBOutlet UIButton *directMessageButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *twitterCenterHeaderButton;
    
	KBTwitterManager *twitterManager;
    XAuthTwitterEngine *twitterEngine;
	KBTwitterLoginView *twLoginView;
}

@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction) flipBetweenMapAndList;
- (IBAction) showMentions;
- (IBAction) showDirectMessages;
- (IBAction) showUserTimeline;
- (IBAction) showSearch;
- (IBAction) openTweetModalView;

- (void)checkMemoryUsage;
-(void)showLoginView;
-(void)killLoginView;
- (BOOL)displaysTwitterUserProfile;
@end

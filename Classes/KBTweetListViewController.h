//
//  KBTweetListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBTwitterViewController.h"
#import "KBTweet.h"
#import "KBTweetTableCell.h"
#import "XAuthTwitterEngineViewController.h"


@interface KBTweetListViewController : KBTwitterViewController <MGTwitterEngineDelegate> {
    NSArray *statuses;
    NSMutableArray *statusObjects;
    NSMutableArray *tweets;
    XAuthTwitterEngineViewController *loginController;
}

- (void) statusRetrieved:(NSNotification *)inNotification;
- (void) showStatuses;
- (void) createNotificationObservers;
- (void) removeNotificationObservers;

@end

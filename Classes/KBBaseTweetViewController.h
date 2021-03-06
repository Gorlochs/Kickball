//
//  KBBaseTweetViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBTwitterViewController.h"
#import "KBTweet.h"
#import "KBTweetTableCell.h"
#import "KBTweetTableCell320.h"
#import "KBTwitterManager.h"
#import "KBTwitterManagerDelegate.h"

#define MAX_LABEL_HEIGHT 68.0

@class KBUserTweetsViewController, KBTwitterSearchViewController, KBTwitterDetailViewController, KBTwitterProfileViewController;

@interface KBBaseTweetViewController : KBTwitterViewController <MGTwitterEngineDelegate, KBTwitterManagerDelegate> {
    NSMutableArray *tweets;
    NSString *cachingKey;
    int pageNum;
    IBOutlet UIView *noResultsView;
    
    BOOL requeryWhenTableGetsToBottom;
    int stuckToBottom;
}

- (void) showStatuses;
- (void) executeQuery:(int)pageNumber;
- (NSMutableArray*) addAndTrimArray:(NSMutableArray*)arrayToAdd;

- (void) viewOtherUserProfile:(NSString*)userName;
 
@end

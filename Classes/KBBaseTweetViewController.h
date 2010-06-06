//
//  KBBaseTweetViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTwitterViewController.h"
#import "KBTweet.h"
#import "KBTweetTableCell.h"
#import "KBTwitterManager.h"
#import "KBTwitterManagerDelegate.h"

#define MAX_LABEL_HEIGHT 68.0

@class KBUserTweetsViewController, KBTwitterSearchViewController, KBTwitterDetailViewController;

@interface KBBaseTweetViewController : KBTwitterViewController <MGTwitterEngineDelegate, KBTwitterManagerDelegate> {
    NSMutableArray *tweets;
    NSString *cachingKey;
    int pageNum;
    NSArray *twitterArray;
    IBOutlet UITableViewCell *moreCell;
    IBOutlet UIView *noResultsView;
	KBTwitterManager *twitterManager;
    KBTwitterDetailViewController *detailViewController;
    KBUserTweetsViewController *userTweetsController;
    KBTwitterSearchViewController *searchController;
}

- (void) showStatuses;
- (void) executeQuery:(int)pageNumber;
- (NSMutableArray*) addAndTrimArray:(NSMutableArray*)arrayToAdd;
 
@end

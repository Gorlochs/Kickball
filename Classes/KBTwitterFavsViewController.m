//
//  KBTwitterFavsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterFavsViewController.h"
#import "Three20/Three20.h"
#import "UIAlertView+Helper.h"
#import "KBTwitterSearchViewController.h"
#import "KBUserTweetsViewController.h"
#import "KBTwitterDetailViewController.h"
#import "MGTwitterEngine.h"
#import "TableSectionHeaderView.h"


@implementation KBTwitterFavsViewController

@synthesize userDictionary;
@synthesize username;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}
 
- (void)viewDidLoad {
	pageType = KBPageTypeOther;
    [super viewDidLoad];
    pageNum = 1;
    cachingKey = [kKBTwitterFavoritesKey retain];
    pageViewType = KBPageViewTypeList;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCanceled) name:@"loginCanceled" object:nil];
    if ([self.twitterEngine isAuthorized]) {
        [self startProgressBar:@"Retrieving your tweets..."];
        [twitterEngine getFavoritesForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
    } else {
        loginController = [[KBTwitterXAuthLoginController alloc] initWithNibName:@"TwitterLoginView_v2" bundle:nil];
        loginController.rootController = self;
        [self presentModalViewController:loginController animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    //overriding the removal of notifications
}

- (void) loginCanceled {
    [self switchToFoursquare];
}

- (void)statusesReceived:(NSArray *)statuses {
  DLog(@"received favorites statuses %@", statuses);
	if (statuses) {
		NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
		for (NSDictionary *dict in statuses) {
			KBTweet *tweet = [[KBTweet alloc] initWithDictionary:dict];
			[tempTweetArray addObject:tweet];
			[tweet release];
		}
		if (pageNum > 1) {
			[tweets addObjectsFromArray:tempTweetArray];
		} else if (!tweets) {
			tweets = [[NSMutableArray alloc] initWithArray:tempTweetArray];
		} else {
			[tempTweetArray addObjectsFromArray:tweets];
//			[tweets release]; //BAD!
			tweets = nil;
			tweets = [[self addAndTrimArray:tempTweetArray] retain];
		}
		[theTableView reloadData];
		[tempTweetArray release];
	}
  [self stopProgressBar];
  [self dataSourceDidFinishLoadingNewData];
  //[[KBTwitterManager twitterManager] cacheStatusArray:tweets withKey:cachingKey];
}

- (void) refreshTable {
    [self showStatuses];
}

#pragma mark -
#pragma mark table methods

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableSectionHeaderView *sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
	sectionHeaderView.leftHeaderLabel.text = [NSString stringWithFormat:@"%@'s favorites", self.username];
	return sectionHeaderView;
}

#pragma mark -
#pragma mark MGTwitterEngineDelegate methods

- (void)requestSucceeded:(NSString *)connectionIdentifier {
	DLog(@"Twitter request succeeded 3: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"Twitter request failed 3: %@ with error:%@", connectionIdentifier, error);
    [self stopProgressBar];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    loginController = nil;
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    loginController = nil;
}


- (void)dealloc {
    [loginController release];
    [userDictionary release];
    [username release];
    [super dealloc];
}


@end


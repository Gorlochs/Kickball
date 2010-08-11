    //
//  KBTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterViewController.h"
#import "KBTwitterManager.h"
#import "KBTweetListViewController.h"
#import "KBMentionsViewController.h"
#import "KBDirectMessagesViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBGeoTweetMapViewController.h"
#import "KBCreateTweetViewController.h"
#import "KBTwitterLoginView.h"
#import "Utilities.h"

@implementation KBTwitterViewController

@synthesize twitterEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

-(void) stopProgressBarAndDisplayErrorMessage:(NSTimer*)theTimer {
    [theTimer invalidate];
    theTimer = nil;
    [self stopProgressBar];
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Twitter Message" andMessage:@"The server is not currently responding. Please try again shortly."];
    [self displayPopupMessage:message];
    [message release];
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
	[self stopProgressBar];
}

- (void)viewDidLoad {
	twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
    twitterEngine = [twitterManager twitterEngine];
    
    //headerNibName = HEADER_NIB_TWITTER;
    footerType = KBFooterTypeTwitter;
    
    [super viewDidLoad];
    
    if (pageType == KBPageTypeOther) {
        homeButton.hidden = NO;
        backButton.hidden = NO;
        directMessageButton.hidden = YES;
        searchButton.hidden = YES;
    }
    
    if (pageViewType == KBPageViewTypeList) {
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap01.png"] forState:UIControlStateNormal];
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap02.png"] forState:UIControlStateHighlighted];
        twitterCenterHeaderButton.enabled = YES;
    } else if (pageViewType == KBPageViewTypeMap) {
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitList01.png"] forState:UIControlStateNormal];
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitList02.png"] forState:UIControlStateHighlighted];
        twitterCenterHeaderButton.enabled = YES;
    } else if (pageViewType == KBPageViewTypeOther) {
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap01.png"] forState:UIControlStateNormal];
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap02.png"] forState:UIControlStateHighlighted];
        twitterCenterHeaderButton.enabled = NO;
    }
    footerType = KBFooterTypeTwitter;
    [self setTabImages];
}

- (void) openTweetModalView {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    [self.navigationController pushViewController:tweetController animated:YES];
	[tweetController release];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"didStartModalTweet" object:nil]; 
}

- (void) flipBetweenMapAndList {
    if (pageViewType == KBPageViewTypeList) {
        KBGeoTweetMapViewController *mapController = [[KBGeoTweetMapViewController alloc] initWithNibName:@"KBGeoTweetMapViewController" bundle:nil];
        [self.navigationController pushViewController:mapController animated:NO];
		[mapController release];
    } else {
        [self backOneViewNotAnimated];
    }
}

- (void) showUserTimeline {
    KBTweetListViewController *controller = [[KBTweetListViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
	[self checkMemoryUsage];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (void)checkMemoryUsage {
	if ([Utilities getMemory] < 1400000) {
	  DLog(@"out of memory - popping");
	  //[self.navigationController popToRootViewControllerAnimated:NO]; // Pops until there's only a single view controller left on the stack. Returns the popped controllers.
	}
}

- (void) showMentions {
    KBMentionsViewController *controller = [[KBMentionsViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
	[self checkMemoryUsage];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (void) showDirectMessages {
    KBDirectMessagesViewController *controller = [[KBDirectMessagesViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (void) showSearch {
    KBTwitterSearchViewController *controller = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTwitterSearchViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

-(void)killLoginView{
	//hide loginView and load user info
	if (twLoginView!=nil) {
		[twLoginView removeFromSuperview];
		twLoginView = nil;
		//[self refreshMainFeed];
		//[self startProgressBar:@"Retrieving news feed..."];
		//[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
		
	}
	
	
}
-(void)showLoginView{
	//fbLoginView = [[KBFacebookLoginView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
	//[self.view addSubview:fbLoginView];
	
	// Ingest the nib. Should there be a copy or retain here?
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"KBTwitterLoginView" owner:self options:nil];
	
    // Pull the view from the nib. Should there be a copy or retain here?
    twLoginView = (KBTwitterLoginView *)[topLevelObjects objectAtIndex:0];
	[twLoginView setDelegate:self];
    twLoginView.frame = CGRectMake(0, 0,320, 419);
	[self.view addSubview:twLoginView];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	//twitterManager.delegate = nil;
    //[twitterEngine release];
    [super dealloc];
}


@end

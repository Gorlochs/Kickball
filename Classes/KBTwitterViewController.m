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
#import "KBTwitterProfileViewController.h"
#import "KickballAppDelegate.h"

@implementation KBTwitterViewController

@synthesize twitterEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}
/*
-(void) stopProgressBarAndDisplayErrorMessage:(NSTimer*)theTimer {
    [theTimer invalidate];
    theTimer = nil;
    [self stopProgressBar];
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Twitter Message" andMessage:@"That's strange, the server didn't respond. Give it another try."];
    [self displayPopupMessage:message];
    [message release];
}*/

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	DLog(@"Twitter request failed: %@ with error:%@", connectionIdentifier, error);
	[self stopProgressBar];
}

- (void) viewDidAppear:(BOOL)animated {
	// just in case a view higher in the stack was dealloc'd that grabbed the twitterManager.delegate from this class
	twitterManager.delegate = self;
    
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //twitterManager.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	//twitterManager.delegate = nil;
}

- (void)viewDidLoad {
    
    twitterManager = [KBTwitterManager twitterManager];
	twitterManager.delegate = self;
    twitterEngine = [twitterManager twitterEngine];
    
    //headerNibName = HEADER_NIB_TWITTER;
    footerType = KBFooterTypeTwitter;
    
    [super viewDidLoad];
    theTableView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
	self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
	
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
- (void) viewUserProfile {
    // take user to their profile
    [FlurryAPI logEvent:@"View User Profile from Top Nav Icon"];
    KBTwitterProfileViewController *pvc = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
	pvc.screenname = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
	[self.navigationController pushViewController:pvc animated:YES];
	[pvc release];
}

- (void) displayProperProfileView:(NSString*)userId {
	[self displaysTwitterUserProfile];
}

- (BOOL)displaysTwitterUserProfile {
    DLog(@"displaying twitter userprofile");
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
		KBTwitterProfileViewController *pvc = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
		pvc.screenname = [[NSUserDefaults standardUserDefaults] objectForKey:@"twittername"];
		[self.navigationController pushViewController:pvc animated:YES];
		[pvc release];
		return YES;
	}
	return NO;
}

- (void)dealloc {
	//twitterManager.delegate = nil;
    //[twitterEngine release];
    [twLoginView release];
    [super dealloc];
}


@end

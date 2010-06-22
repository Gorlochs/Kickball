//
//  KBFacebookViewController.m
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookViewController.h"
#import "KBFacebookEventsListViewController.h"
#import "KBFacebookListViewController.h"
#import "KBFacebookCreateWallPostVC.h"
#import "KBCreateTweetViewController.h"
#import "FBFacebookCreatePostViewController.h"


@implementation KBFacebookViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	fbLoginView = nil;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killLoginView) name:@"completedFacebookLogin" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginView) name:@"completedFacebookLogout" object:nil];
	
    /*if (!self.hideHeader) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:HEADER_NIB_FACEBOOK owner:self options:nil];
        facebookHeaderView = [nibViews objectAtIndex:0];
        [self.view addSubview:facebookHeaderView];
    }*/
    
	[self setProperFacebookButtons];
}
- (void) setProperFacebookButtons {
	if (pageType == KBpageTypeEvents) {
        [friendButton setImage:[UIImage imageNamed:@"btn-fbFriendsTab02.png"] forState:UIControlStateNormal];
        [eventButton setImage:[UIImage imageNamed:@"btn-fbEvents01.png"] forState:UIControlStateNormal];
        eventButton.enabled = NO;
    } else if (pageType == KBPageTypeFriends) {
        [friendButton setImage:[UIImage imageNamed:@"btn-fbFriendTab01.png"] forState:UIControlStateNormal];
		[friendButton setImage:[UIImage imageNamed:@"btn-fbFriendTab01.png"] forState:UIControlStateDisabled];
        [eventButton setImage:[UIImage imageNamed:@"btn-fbEvents02.png"] forState:UIControlStateNormal];
        friendButton.enabled = NO;
    } else if (pageType == KBPageTypeOther) {
        friendButton.enabled = NO;
        homeButton.hidden = NO;
        backButton.hidden = NO;
        eventButton.hidden = YES;
        [eventButton setImage:[UIImage imageNamed:@"btn-fbEvents01.png"] forState:UIControlStateNormal];
    }
    
    if (pageViewType == KBPageViewTypeList) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"fbMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"fbMap02.png"] forState:UIControlStateHighlighted];
    } else if (pageViewType == KBPageViewTypeMap) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"fbList01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"fbList02.png"] forState:UIControlStateHighlighted];
    } else if (pageViewType == KBPageViewTypeOther) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"fbMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"fbMap02.png"] forState:UIControlStateHighlighted];
        centerHeaderButton.enabled = NO;
    }
	footerType = KBFooterTypeFacebook;
	[self setTabImages];
}
- (void) viewEvents {
    if (pageViewType == KBPageViewTypeList) {
        KBFacebookEventsListViewController *eventsController = [[KBFacebookEventsListViewController alloc] initWithNibName:@"KBFacebookEventsListView" bundle:nil];
        [self.navigationController pushViewController:eventsController animated:NO];
        [eventsController release];
    } else if (pageViewType == KBPageViewTypeMap) {
        //PlacesMapViewController *placesController = [[PlacesMapViewController alloc] initWithNibName:@"PlacesMapView_v2" bundle:nil];
        //[self.navigationController pushViewController:placesController animated:NO];
        //[placesController release];
    }
}

- (void) viewFriends {
    if (pageViewType == KBPageViewTypeList) {
		//if you are in list view than the friends list view is the top of the stack.
		//DO NOT alloc a new view controller, just pop to the top of the stack!
		[self.navigationController popToRootViewControllerAnimated:NO];
        /*
		KBFacebookListViewController *friendsController = [[KBFacebookListViewController alloc] initWithNibName:@"KBFacebookListViewController" bundle:nil];
        [self.navigationController pushViewController:friendsController animated:NO];
        [friendsController release];
		 */
    } else if (pageViewType == KBPageViewTypeMap) {
        //FriendsMapViewController *friendsController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView_v2" bundle:nil];
        //[self.navigationController pushViewController:friendsController animated:NO];
        //[friendsController release];
    }
}

- (void) backOneView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) backOneViewNotAnimated {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) goToHomeView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) goToHomeViewNotAnimated {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction) openStatusModalView {
    //KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    //[self presentModalViewController:tweetController animated:YES];
	//[tweetController release];
	//KBFacebookCreateWallPostVC *wallPostController = [[KBFacebookCreateWallPostVC alloc] initWithNibName:@"KBFacebookCreateWallPostVC" bundle:nil];
    //[self.navigationController pushViewController:wallPostController animated:YES];
	//[wallPostController release];
	
	FBFacebookCreatePostViewController *tweetController = [[FBFacebookCreatePostViewController alloc] initWithNibName:@"FBFacebookCreatePostViewController" bundle:nil];
    [self.navigationController pushViewController:tweetController animated:YES];
	[tweetController release];
}

-(void)killLoginView{
	//hide loginView and load user info
	if (fbLoginView!=nil) {
		[fbLoginView removeFromSuperview];
		//[fbLoginView release];
		fbLoginView = nil;
		//[self refreshMainFeed];
		[self startProgressBar:@"Retrieving news feed..."];
		[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
		
	}
	
}
-(void)showLoginView{
	// Ingest the nib. Should there be a copy or retain here?
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"KBFacebookLoginView" owner:self options:nil];
	
    // Pull the view from the nib. Should there be a copy or retain here?
    fbLoginView = (KBFacebookLoginView *)[topLevelObjects objectAtIndex:0];
	
	//fbLoginView = [[KBFacebookLoginView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
	[fbLoginView setFrame:CGRectMake(0, 0, 320, 420)];
	[self.view addSubview:fbLoginView];
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

- (void) showBackHomeButtons {
    homeButton.hidden = NO;
    backButton.hidden = NO;
}



- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [friendButton release];
    [eventButton release];
    [centerHeaderButton release];
    [homeButton release];
    [backButton release];
    //[facebookHeaderView release];
    [super dealloc];
}


@end



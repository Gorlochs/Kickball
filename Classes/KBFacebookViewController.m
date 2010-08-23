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
#import "KBCreateTweetViewController.h"
#import "FBFacebookCreatePostViewController.h"
#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "MockPhotoSource.h"
#import "KBThumbnailViewController.h"
#import "KBGenericPhotoViewController.h"

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

- (void) flipBetweenMapAndList {}

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

-(void)displayAlbum:(NSString*)aid atIndex:(NSNumber*)index{
	[self startProgressBar:@"loading photos"];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	NSArray* photos = [graph getPhotosForAlbum:aid];
	MockPhoto *photoIndex = nil;
	NSMutableArray *tempTTPhotoArray = [[NSMutableArray alloc] initWithCapacity:[photos count]];
	int i = 1;
    for (NSDictionary *pic in photos) {
        MockPhoto *photo = [[MockPhoto alloc] initWithURL:[pic objectForKey:@"src_big"] smallURL:[pic objectForKey:@"src_small"] size:CGSizeMake([[pic objectForKey:@"src_big_width"] intValue], [[pic objectForKey:@"src_big_height"] intValue]) caption:[pic objectForKey:@"caption"]];
        [tempTTPhotoArray addObject:photo];
		if (i==[index intValue]) {
			photoIndex = [photo retain];
		}
        [photo release];
		i++;
    }
	
    MockPhotoSource *thePhotoSource = [[MockPhotoSource alloc] initWithType:MockPhotoSourceNormal title:[[FacebookProxy instance] albumNameFrom:aid] photos:tempTTPhotoArray photos2:nil];
	KBGenericPhotoViewController *thumbsController = [[KBGenericPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
	self.title = @"facebook";
	thumbsController.title = [[FacebookProxy instance] albumNameFrom:aid];
	//thumbsController.photoSource = thePhotoSource;
	thumbsController.centerPhoto = photoIndex;
    //thumbsController.navigationBarStyle = UIBarStyleBlackOpaque;
    //thumbsController.statusBarStyle = UIStatusBarStyleBlackOpaque;
    [self.navigationController pushViewController:thumbsController animated:YES];
    [thumbsController release]; 
	
	[thePhotoSource release];
	[tempTTPhotoArray release];
	[graph release];
	[photoIndex release];

	//[pool release];
	
	
	[self stopProgressBar];
	
	
}
-(void)displayAlbum:(NSString*)aid{
	[self startProgressBar:@"loading photos"];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	NSArray* photos = [graph getPhotosForAlbum:aid];
	
	NSMutableArray *tempTTPhotoArray = [[NSMutableArray alloc] initWithCapacity:[photos count]];
    for (NSDictionary *pic in photos) {
        MockPhoto *photo = [[MockPhoto alloc] initWithURL:[pic objectForKey:@"src_big"] smallURL:[pic objectForKey:@"src_small"] size:CGSizeMake([[pic objectForKey:@"src_big_width"] intValue], [[pic objectForKey:@"src_big_height"] intValue]) caption:[pic objectForKey:@"caption"]];
        [tempTTPhotoArray addObject:photo];
        [photo release];
    }
	
    MockPhotoSource *thePhotoSource = [[MockPhotoSource alloc] initWithType:MockPhotoSourceNormal title:[[FacebookProxy instance] albumNameFrom:aid] photos:tempTTPhotoArray photos2:nil];
	KBGenericPhotoViewController *thumbsController = [[KBGenericPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
	self.title = @"facebook";
	thumbsController.title = [[FacebookProxy instance] albumNameFrom:aid];
	//thumbsController.photoSource = thePhotoSource;
    thumbsController.navigationBarStyle = UIBarStyleBlackOpaque;
    thumbsController.statusBarStyle = UIStatusBarStyleBlackOpaque;
    [self.navigationController pushViewController:thumbsController animated:YES];
    [thumbsController release]; 
	
	//KBGenericPhotoViewController *photoController = [[KBGenericPhotoViewController alloc] initWithPhotoSource:thePhotoSource];
    //photoController.centerPhoto = [thePhotoSource photoAtIndex:0];  // sets the photo displayer to the correct image
    //[self.navigationController pushViewController:photoController animated:YES];
    //[photoController release];
	[thePhotoSource release];
	[tempTTPhotoArray release];
	[graph release];
	//[pool release];
	
	
	[self stopProgressBar];


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



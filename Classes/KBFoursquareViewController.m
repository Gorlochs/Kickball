    //
//  KBFoursquareViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBFoursquareViewController.h"
#import "PlacesListViewController.h"
#import "PlacesMapViewController.h"
#import "FriendsListViewController.h"
#import "FriendsMapViewController.h"
#import "KBFoursquareLoginView.h"



@implementation KBFoursquareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	fsLoginView = nil;
    
    ///headerNibName = HEADER_NIB_FOURSQUARE;
    footerType = KBFooterTypeFoursquare;
	
    [super viewDidLoad];
    
	[self setProperFoursquareButtons];
}

- (void) setProperFoursquareButtons {
	if (pageType == KBPageTypePlaces) {
        [friendButton setImage:[UIImage imageNamed:@"btn-Friends03.png"] forState:UIControlStateNormal];
        [placesButton setImage:[UIImage imageNamed:@"placesTab01.png"] forState:UIControlStateNormal];
        placesButton.enabled = NO;
    } else if (pageType == KBPageTypeFriends) {
        [friendButton setImage:[UIImage imageNamed:@"btn-Friends01.png"] forState:UIControlStateNormal];
        [placesButton setImage:[UIImage imageNamed:@"placesTab03.png"] forState:UIControlStateNormal];
        friendButton.enabled = NO;
    } else if (pageType == KBPageTypeOther) {
        friendButton.enabled = NO;
        homeButton.hidden = NO;
        backButton.hidden = NO;
        placesButton.hidden = YES;
        [placesButton setImage:[UIImage imageNamed:@"placesTab01.png"] forState:UIControlStateNormal];
    }
    
    if (pageViewType == KBPageViewTypeList) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"btn-4sqMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"btn-4sqMap02.png"] forState:UIControlStateHighlighted];
    } else if (pageViewType == KBPageViewTypeMap) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"kbList01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"kbList02.png"] forState:UIControlStateHighlighted];
    } else if (pageViewType == KBPageViewTypeOther) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"btn-4sqMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"btn-4sqMap02.png"] forState:UIControlStateHighlighted];
        centerHeaderButton.enabled = NO;
    }
}

- (void) viewPlaces {
    if (pageViewType == KBPageViewTypeList) {
        PlacesListViewController *placesController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListView_v2" bundle:nil];
        [self.navigationController pushViewController:placesController animated:NO];
        [placesController release];
    } else if (pageViewType == KBPageViewTypeMap) {
        PlacesMapViewController *placesController = [[PlacesMapViewController alloc] initWithNibName:@"PlacesMapView_v2" bundle:nil];
        [self.navigationController pushViewController:placesController animated:NO];
        [placesController release];
    }
}

- (void) viewFriends {
    if (pageViewType == KBPageViewTypeList) {
        FriendsListViewController *friendsController = [[FriendsListViewController alloc] initWithNibName:@"FriendsListView_v2" bundle:nil];
        [self.navigationController pushViewController:friendsController animated:NO];
        [friendsController release];
    } else if (pageViewType == KBPageViewTypeMap) {
        FriendsMapViewController *friendsController = [[FriendsMapViewController alloc] initWithNibName:@"FriendsMapView_v2" bundle:nil];
        [self.navigationController pushViewController:friendsController animated:NO];
        [friendsController release];
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

- (void) flipBetweenMapAndList {
    DLog(@"!!!!!!!! THIS SHOULDN'T APPEAR!!!!!!!!!!");
}

-(void)killLoginView{
	//hide loginView and load user info
	if (fsLoginView!=nil) {
		[fsLoginView removeFromSuperview];
		fsLoginView = nil;
		//[self refreshMainFeed];
		//[self startProgressBar:@"Retrieving news feed..."];
		//[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
		
	}
	
}
-(void)showLoginView{
	//fbLoginView = [[KBFacebookLoginView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
	//[self.view addSubview:fbLoginView];
	// Ingest the nib. Should there be a copy or retain here?
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"KBFoursquareLoginView" owner:self options:nil];
	
    // Pull the view from the nib. Should there be a copy or retain here?
    fsLoginView = (KBFoursquareLoginView *)[topLevelObjects objectAtIndex:0];
	[fsLoginView setDelegate:self];
    fsLoginView.frame = CGRectMake(0, 0,320, 419);
	[self.view addSubview:fsLoginView];
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
//    [friendButton release];
//    [placesButton release];
//    [centerHeaderButton release];
//    [homeButton release];
//    [backButton release];
    [super dealloc];
}


@end

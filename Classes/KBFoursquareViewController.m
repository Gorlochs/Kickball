    //
//  KBFoursquareViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBFoursquareViewController.h"
#import "PlacesListViewController.h"

@implementation KBFoursquareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (pageType == KBPageTypePlaces) {
        [friendButton setImage:[UIImage imageNamed:@"friendsTab03.png"] forState:UIControlStateNormal];
        [placesButton setImage:[UIImage imageNamed:@"placesTab01.png"] forState:UIControlStateNormal];
        placesButton.enabled = NO;
    } else if (pageType == KBPageTypeFriends) {
        [friendButton setImage:[UIImage imageNamed:@"friendsTab01.png"] forState:UIControlStateNormal];
        [placesButton setImage:[UIImage imageNamed:@"placesTab03.png"] forState:UIControlStateNormal];
        friendButton.enabled = NO;
    }
    
    if (pageViewType == KBPageViewTypeList) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"kbMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"kbMap02.png"] forState:UIControlStateHighlighted];
    } else if (pageType == KBPageViewTypeMap) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"kbList01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"kbList03.png"] forState:UIControlStateHighlighted];
    }
}


- (void) viewPlacesList {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListView_v2" bundle:nil];
    [self.navigationController pushViewController:placesListController animated:NO];
    [placesListController release];
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

- (void) flipToMap {
    NSLog(@"!!!!!!!! THIS SHOULDN'T APPEAR!!!!!!!!!!");
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
    [super dealloc];
}


@end

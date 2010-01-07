//
//  SettingsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewFriendRequestsViewController.h"
#import "FriendRequestsViewController.h"
#import "FoursquareAPI.h"


@implementation SettingsViewController

- (void)viewDidLoad {
    username.text = [[FoursquareAPI sharedInstance] userName];
    password.text = [[FoursquareAPI sharedInstance] passWord];
    [super viewDidLoad];
}

- (void) viewFriendRequests {
    ViewFriendRequestsViewController *friendRequestsController = [[ViewFriendRequestsViewController alloc] initWithNibName:@"ViewFriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendRequestsController animated:YES];
    [friendRequestsController release];
}

- (void) addFriends {
    FriendRequestsViewController *friendRequestsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendRequestsController animated:YES];
    [friendRequestsController release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [username release];
    [password release];
    [friendRequestCount release];
    [super dealloc];
}


@end

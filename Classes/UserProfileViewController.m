//
//  UserProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/14/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserProfileFriendsViewController.h"
#import "UserProfileCheckinHistoryViewController.h"

@implementation UserProfileViewController


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) displayStuff {
    UserProfileViewController *profileController = [[UserProfileViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
    profileController.userId = userId;
    [self.navigationController pushViewController:profileController animated:NO];
    [profileController release];
}

- (void) displayFriends {
    UserProfileFriendsViewController *profileController = [[UserProfileFriendsViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
    profileController.userId = userId;
    [self.navigationController pushViewController:profileController animated:NO];
    [profileController release];
}

- (void) displayCheckinHistory {
    UserProfileCheckinHistoryViewController *profileController = [[UserProfileCheckinHistoryViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
    profileController.userId = userId;
    [self.navigationController pushViewController:profileController animated:NO];
    [profileController release];
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
    [yourStuffButton release];
    [yourFriendsButton release];
    [checkinHistoryButton release];
    [super dealloc];
}


@end

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


- (void)viewDidLoad {
    [super viewDidLoad];
    yourStuffButton.enabled = NO;
    yourFriendsButton.enabled = YES;
    checkinHistoryButton.enabled = YES;
    [yourStuffButton setImage:[UIImage imageNamed:@"myProfileStuffTab01.png"] forState:UIControlStateDisabled];
    [yourFriendsButton setImage:[UIImage imageNamed:@"myProfileFriendsTab02.png"] forState:UIControlStateNormal];
    [checkinHistoryButton setImage:[UIImage imageNamed:@"myProfileHistoryTab03.png"] forState:UIControlStateNormal];
    
    if (self.user) {
        [self setAllUserFields:self.user];
    }
}

// user is used to set the user header stuff so we don't have to make an API call
// userId is used for the parent's API call
- (void) displayStuff {
    UserProfileViewController *profileController = [[UserProfileViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
    profileController.user = user;
    profileController.userId = userId;
    [self.navigationController pushViewController:profileController animated:NO];
    [profileController release];
}

- (void) displayFriends {
    UserProfileFriendsViewController *profileController = [[UserProfileFriendsViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
    profileController.user = user;
    profileController.userId = userId;
    [self.navigationController pushViewController:profileController animated:NO];
    [profileController release];
}

- (void) displayCheckinHistory {
    UserProfileCheckinHistoryViewController *profileController = [[UserProfileCheckinHistoryViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
    profileController.user = user;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (void)dealloc {
    [yourStuffButton release];
    [yourFriendsButton release];
    [checkinHistoryButton release];
    [super dealloc];
}


@end

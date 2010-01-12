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

- (void) viewWillAppear:(BOOL)animated {
    [[FoursquareAPI sharedInstance] getPendingFriendRequests:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
    [super viewWillAppear:animated];
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"pending friend requests: %@", inString);
    pendingFriendRequests = [FoursquareAPI usersFromRequestResponseXML:inString];
    friendRequestCount.text = [NSString stringWithFormat:@"%d", [pendingFriendRequests count]];
    [self stopProgressBar];
    NSLog(@"pendingFriendRequests: %@", pendingFriendRequests);
    
    //    KBMessage *message = [[KBMessage alloc] initWithMember:@"Friend Request" andSubtitle:@"Complete!" andMessage:@"Your future buddy has been sent a friend request."];
    //    [self displayPopupMessage:message];
    //    [message release];
}

- (void) viewFriendRequests {
    ViewFriendRequestsViewController *friendRequestsController = [[ViewFriendRequestsViewController alloc] initWithNibName:@"ViewFriendRequestsViewController" bundle:nil];
    friendRequestsController.pendingFriendRequests = [[NSMutableArray alloc] initWithArray:pendingFriendRequests];
    [self.navigationController pushViewController:friendRequestsController animated:YES];
    [friendRequestsController release];
}

- (void) addFriends {
    FriendRequestsViewController *friendRequestsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendRequestsController animated:YES];
    [friendRequestsController release];
}

- (void) validateNewUsernamePassword {
    
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

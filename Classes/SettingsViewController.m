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
#import "SFHFKeychainUtils.h"
#import "LoginViewModalController.h"


@implementation SettingsViewController

- (void)viewDidLoad {
    username.text = [[FoursquareAPI sharedInstance] userName];
    password.text = [[FoursquareAPI sharedInstance] passWord];
    [[Beacon shared] startSubBeaconWithName:@"Settings View"];
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [self startProgressBar:@"Retrieving settings..."];
    [[FoursquareAPI sharedInstance] getPendingFriendRequests:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
    [super viewWillAppear:animated];
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"pending friend requests: %@", inString);
    pendingFriendRequests = [[FoursquareAPI usersFromRequestResponseXML:inString] retain];
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
    [self startProgressBar:@"Retrieving new username and password..."];
    [[FoursquareAPI sharedInstance] getFriendsWithTarget:username.text andPassword:password.text andTarget:self andAction:@selector(friendResponseReceived:withResponseString:)];
}


- (void)friendResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"friend response for login: %@", inString);
    [username resignFirstResponder];
    [password resignFirstResponder];
    [self stopProgressBar];
    // cheap way of checking for successful authentication
    BOOL containsUnauthorized = [inString rangeOfString:@"unauthorized" options:NSCaseInsensitiveSearch].length > 0;
    if (containsUnauthorized) {
        // display fail message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Failed!" andMessage:@"Authentication failed. Please try again."];
        [self displayPopupMessage:message];
        [message release];
    } else {
        // display success message and save to keychain
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded!  Your new username and password have been authenticated."];
        [self displayPopupMessage:message];
        [message release];
        
        [[FoursquareAPI sharedInstance] doLoginUsername: username.text andPass:password.text];	
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:username.text forKey:kUsernameDefaultsKey];
        NSLog(@"Stored username: %@", username.text);
        
        NSError *error = nil;
        [SFHFKeychainUtils storeUsername:username.text
                             andPassword:password.text
                          forServiceName:@"Kickball" 
                          updateExisting:YES error:&error];
    }
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

- (void) togglePingsAndUpdates {
    [self startProgressBar:@"Changing your ping update preferences..."];
    //NSArray *yesnoArray = [NSArray arrayWithObjects:@"off", @"on", nil];
    NSString *ping = @"on";
    if (isPingAndUpdatesOn) {
        ping = @"off";
    }
    [[FoursquareAPI sharedInstance] setPings:ping forUser:nil withTarget:self andAction:@selector(pingUpdateResponseReceived:withResponseString:)];
}

- (void) pingUpdateResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	BOOL newPingSetting = [FoursquareAPI pingSettingFromResponseXML:inString];
    NSLog(@"new ping setting: %d", newPingSetting);
    isPingAndUpdatesOn = !isPingAndUpdatesOn;
    //pingsAndUpdates.selected = isPingAndUpdatesOn;
    if (isPingAndUpdatesOn) {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings01.png"] forState:UIControlStateNormal];
    } else {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"profilePings03.png"] forState:UIControlStateNormal];
    }
    [self stopProgressBar];
}

- (void)dealloc {
    [username release];
    [password release];
    [friendRequestCount release];
    [pendingFriendRequests release];
    [super dealloc];
}


@end

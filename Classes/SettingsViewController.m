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
#import "Utilities.h"


@implementation SettingsViewController

- (void)viewDidLoad {
    DLog(@"auth'd user: %@", [self getAuthenticatedUser]);
    username.text = [[FoursquareAPI sharedInstance] userName];
    password.text = [[FoursquareAPI sharedInstance] passWord];
    [FlurryAPI logEvent:@"Settings View"];
    
    isPingAndUpdatesOn = [self getAuthenticatedUser].isPingOn;
    [self setPingAndUpdatesButton];
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [self startProgressBar:@"Retrieving settings..."];
    [[FoursquareAPI sharedInstance] getPendingFriendRequests:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
    [super viewWillAppear:animated];
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        DLog(@"pending friend requests: %@", inString);
		if (pendingFriendRequests!=nil) {
			[pendingFriendRequests release];
			pendingFriendRequests = nil;
		}
        pendingFriendRequests = [[FoursquareAPI usersFromRequestResponseXML:inString] retain];
        friendRequestCount.text = [NSString stringWithFormat:@"%d", [pendingFriendRequests count]];
    }
    [self stopProgressBar];
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
    DLog(@"friend response for login: %@", inString);
    [username resignFirstResponder];
    [password resignFirstResponder];
    [self stopProgressBar];
    // cheap way of checking for successful authentication
    BOOL containsUnauthorized = [inString rangeOfString:@"unauthorized" options:NSCaseInsensitiveSearch].length > 0;
    if (containsUnauthorized) {
        // display fail message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Failed!" andMessage:@"Authentication failed. Give it another try."];
        [self displayPopupMessage:message];
        [message release];
    } else {
        // display success message and save to keychain
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded! Your username and password have been authenticated."];
        [self displayPopupMessage:message];
        [message release];
        
        [[FoursquareAPI sharedInstance] doLoginUsername: username.text andPass:password.text];	
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:username.text forKey:kUsernameDefaultsKey];
		[prefs synchronize];
        DLog(@"Stored username: %@", username.text);
        
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
    NSString *ping = @"on";
    if (isPingAndUpdatesOn) {
        ping = @"off";
    }
    [[FoursquareAPI sharedInstance] setPings:ping forUser:@"self" withTarget:self andAction:@selector(pingUpdateResponseReceived:withResponseString:)];
}

- (void) pingUpdateResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"instring: %@", inString);
	BOOL newPingSetting = [FoursquareAPI pingSettingFromResponseXML:inString];
    DLog(@"new ping setting: %d", newPingSetting);
    isPingAndUpdatesOn = !isPingAndUpdatesOn;
    [self setPingAndUpdatesButton];
    [self stopProgressBar];
}

- (void) setPingAndUpdatesButton {
    if (isPingAndUpdatesOn) {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"settingsCheckins01.png"] forState:UIControlStateNormal];
        [pingsAndUpdates setImage:[UIImage imageNamed:@"settingsCheckins02.png"] forState:UIControlStateHighlighted];
    } else {
        [pingsAndUpdates setImage:[UIImage imageNamed:@"settingsCheckins03.png"] forState:UIControlStateNormal];
        [pingsAndUpdates setImage:[UIImage imageNamed:@"settingsCheckins02.png"] forState:UIControlStateHighlighted];
    }
}

- (void) cancelEdit {
    [username resignFirstResponder];
    [password resignFirstResponder];

    [self.view addSubview:toolbar];
    [self animateToolbar:CGRectMake(0, 480, 320, 44)];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    toolbar.frame = CGRectMake(0, 480, 320, 40);
    [self.view addSubview:toolbar];
    [self animateToolbar:CGRectMake(0, 201, 320, 44)];
}

- (void) animateToolbar:(CGRect)toolbarFrame {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [toolbar setFrame:toolbarFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
	if (theTextField == password) {
        toolbar.hidden = YES;
		[password resignFirstResponder];
		[self validateNewUsernamePassword];
        // Invoke the method that changes the greeting.
	} else if (theTextField == username) {
		[password becomeFirstResponder];
		// Invoke the method that changes the greeting.
		
	}
	return YES;
}

- (void) chooseCityRadius {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (cityRadiusControl.selectedSegmentIndex == 0) {
        [userDefaults setInteger:50000 forKey:kCityRadiusKey];
    } else if (cityRadiusControl.selectedSegmentIndex == 1) {
        [userDefaults setInteger:100000 forKey:kCityRadiusKey];
    } else if (cityRadiusControl.selectedSegmentIndex == 2) {
        [userDefaults setInteger:250000 forKey:kCityRadiusKey];
    }
}

- (void)dealloc {
    [username release];
    [password release];
    [friendRequestCount release];
    [pendingFriendRequests release];
    [toolbar release];
    [cityRadiusControl release];
    [super dealloc];
}


@end

//
//  AccountOptionsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "AccountOptionsViewController.h"
#import "FoursquareAPI.h"
#import "SFHFKeychainUtils.h"

@implementation AccountOptionsViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    
    [super viewDidLoad];
}

#pragma mark -
#pragma mark IBAction

- (void) authenticateFoursquare {
    NSLog(@"auth 4sq click");
    if ([foursquareUsername.text length] > 0 && [foursquarePassword.text length] > 0) {
        [self startProgressBar:@"Authenticating new username and password..."];
        [foursquareUsername resignFirstResponder];
        [foursquarePassword resignFirstResponder];
        [[FoursquareAPI sharedInstance] getUserWithUsername:foursquareUsername.text andPassword:foursquarePassword.text withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
//        [[FoursquareAPI sharedInstance] getFriendsWithTarget:username.text andPassword:password.text andTarget:self andAction:@selector(friendResponseReceived:withResponseString:)];
    } else {
        // TODO: popup error message
    }
}

- (void) authenticateTwitter {
    
}

- (void) linkKickballAccount {
    
}

- (void) enableTwitterGeotagging {
    
}

- (void) postPhotosToFacebook {
    
}

- (void) displayWhatsThis {
    
}

#pragma mark -
#pragma mark delgate callbacks

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"friend response for login: %@", inString);
    [self stopProgressBar];
    // cheap way of checking for successful authentication
    BOOL containsUnauthorized = [inString rangeOfString:@"unauthorized" options:NSCaseInsensitiveSearch].length > 0;
    if (containsUnauthorized) {
        // display fail message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Failed!" andMessage:@"Authentication failed. Please try again."];
        [self displayPopupMessage:message];
        [message release];
    } else {
        [[FoursquareAPI sharedInstance] doLoginUsername: foursquareUsername.text andPass:foursquarePassword.text];	
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:foursquareUsername.text forKey:kUsernameDefaultsKey];
        NSLog(@"Stored username: %@", foursquareUsername.text);
        
        NSError *error = nil;
        [SFHFKeychainUtils storeUsername:foursquareUsername.text
                             andPassword:foursquarePassword.text
                          forServiceName:@"Kickball" 
                          updateExisting:YES error:&error];
        
        FSUser* user = [[FoursquareAPI userFromResponseXML:inString] retain];
        [self setAuthenticatedUser:user];
        
        // display success message and save to keychain
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded!  Your new username and password have been authenticated."];
        [self displayPopupMessage:message];
        [message release];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 229;
    } else if (indexPath.row == 1) {
        return 211;
    } else {
        return 159;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }

    if (indexPath.row == 0) {
        return foursquareCell;
    } else if (indexPath.row == 1) {
        return twitterCell;
    } else {
        return facebookCell;
    }
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end


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
#import "XAuthTwitterEngine.h"

@implementation AccountOptionsViewController

@synthesize twitterEngine;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    isWhatsThisDisplayed = NO;
    
    [super viewDidLoad];
    
    //
	// Initialize the XAuthTwitterEngine.
	//
	self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
	self.twitterEngine.consumerKey = kOAuthConsumerKey;
	self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
}

#pragma mark -
#pragma mark IBAction

- (void) authenticateFoursquare {
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

- (void) linkKickballAccount {
    
}

- (void) enableTwitterGeotagging {
    
}

- (void) postPhotosToFacebook {
    
}

- (void) displayWhatsThis {
    isWhatsThisDisplayed = YES;
    [theTableView reloadData];
}

#pragma mark -
#pragma mark twitter auth methods

- (IBAction)xAuthAccessTokenRequestButtonTouchUpInside
{
    [twitterUsername resignFirstResponder];
    [twitterPassword resignFirstResponder];
    
    [self startProgressBar:@"Authenticating Twitter username and password..."];
    
	NSString *username = twitterUsername.text;
	NSString *password = twitterPassword.text;
	
	NSLog(@"About to request an xAuth token exchange for username: ]%@[ password: ]%@[.", username, password);
	
	[self.twitterEngine exchangeAccessTokenForUsername:username password:password];
}

#pragma mark XAuthTwitterEngineDelegate methods

- (void) storeCachedTwitterXAuthAccessTokenString: (NSString *)tokenString forUsername:(NSString *)username
{
	// FIXME
	// Note: do not use NSUserDefaults to store this in a production environment. 
	// ===== Use the keychain instead. Check out SFHFKeychainUtils if you want 
	//       an easy to use library. (http://github.com/ldandersen/scifihifi-iphone) 
	//
	NSLog(@"Access token string returned: %@", tokenString);
	
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginNotification"
//                                                        object:nil
//                                                      userInfo:nil];
    
    [self stopProgressBar];
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded!  Your new username and password have been authenticated."];
    [self displayPopupMessage:message];
    [message release];
    
    //[self dismissModalViewControllerAnimated:YES];
}

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

- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error;
{
	NSLog(@"Error: %@", error);
	
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Error!" andMessage:@"Authentication error! Please check your username and password and try again."];
    [self displayPopupMessage:message];
    [message release];
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
        return !isWhatsThisDisplayed ? 229 : 355;
    } else if (indexPath.row == 1) {
        return 211;
    } else {
        return 159;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (isWhatsThisDisplayed) {
            CGRect frame = whyThisImage.frame;
            frame.origin = CGPointMake(17, 220);
            whyThisImage.frame = frame;
            [foursquareCell addSubview:whyThisImage];
            
            [whatIsThisButton removeFromSuperview];
        }
        return foursquareCell;
    } else if (indexPath.row == 1) {
        return twitterCell;
    } else {
        return facebookCell;
    }
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


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
    
//    FBLoginButton* button = [[[FBLoginButton alloc] init] autorelease];
//    button.style = FBLoginButtonStyleWide;
//    
//    button.frame = CGRectMake([self view].frame.size.width/2 - button.frame.size.width/2, 
//                              [self view].frame.size.height/2 - button.frame.size.height/2,
//                              button.frame.size.width, 
//                              button.frame.size.height);
//    [self.view addSubview:button];
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
#pragma mark Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"text field did begin editing: %@", textField);
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    NSLog(@"animated distance: %f", animatedDistance);
    NSLog(@"viewframe origin y: %f", viewFrame.origin.y);
    
//    // toolbar stuff
//    toolbar.hidden = NO;
//    CGRect toolbarFrame = toolbar.frame;
//    
//    // SUPER HACK!!!
//    if (textField == placeName) {
//        toolbarFrame.origin.y = 200;
//    } else if (textField == address) {
//        toolbarFrame.origin.y = 241;
//    } else if (textField == crossstreet) {
//        toolbarFrame.origin.y = 288;
//        //    } else if (textField == city) {
//        //        toolbarFrame.origin.y = 300;
//        //    } else if (textField == state || textField == zip) {
//        //        toolbarFrame.origin.y = 337;
//    } else if (textField == twitter || textField == phone) {
//        toolbarFrame.origin.y = 330;
//    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
//    [toolbar setFrame:toolbarFrame];
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //NSLog(@"text field did end editing: %@", textField);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[self cancelEditing];
    return YES;
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
    foursquareCell = nil;
    twitterCell = nil;
    facebookCell = nil;
    whyThisImage = nil;
    
    foursquareUsername = nil;
    foursquarePassword = nil;
    twitterUsername = nil;
    twitterPassword = nil;
    
    kickballAccountLinkingSwitch = nil;
    twitterGeotaggingSwitch = nil;
    postPhotosToFacebookSwitch = nil;
    
    whatIsThisButton = nil;
    twitterEngine = nil;
}


- (void)dealloc {
    [foursquareCell release];
    [twitterCell release];
    [facebookCell release];
    [whyThisImage release];
    
    [foursquareUsername release];
    [foursquarePassword release];
    [twitterUsername release];
    [twitterPassword release];
    
    [kickballAccountLinkingSwitch release];
    [twitterGeotaggingSwitch release];
    [postPhotosToFacebookSwitch release];
    
    [whatIsThisButton release];
    [twitterEngine release];
    
    [super dealloc];
}


@end

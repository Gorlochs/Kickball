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
#import "KBAccountManager.h"
#import "FeedbackViewController.h"
#import "FacebookProxy.h"
#import "ASIFormDataRequest.h"
#import "KBTwitterManager.h"
#import "OptionsNavigationController.h"
#import "KickballAppDelegate.h"

@implementation AccountOptionsViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    isWhatsThisDisplayed = NO;
	postPhotosToFacebookSwitch.on = [[KBAccountManager sharedInstance] shouldPostPhotosToFacebook];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoggedIn) name:@"completedFacebookLogin" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoggedOut) name:@"completedFacebookLogout" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterLoggedIn) name:@"completedTwitterLogin" object:nil];
    [super viewDidLoad];
    
    //
	// Initialize the XAuthTwitterEngine.
	//
//	self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
//	self.twitterEngine.consumerKey = kOAuthConsumerKey;
//	self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
    fbButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	if ([[FacebookProxy instance] isAuthorized] ) {
		[fbButton setFrame:CGRectMake(facebookCell.frame.size.width/2 - 90/2, 50, 90, 31)];
		[fbButton setImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
		[fbButton addTarget:[FacebookProxy instance] action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
	}else {
		[fbButton setFrame:CGRectMake(facebookCell.frame.size.width/2 - 176/2, 50, 176, 31)];
		[fbButton setImage:[UIImage imageNamed:@"login2.png"] forState:UIControlStateNormal];
		[fbButton addTarget:[FacebookProxy instance] action:@selector(doAuth) forControlEvents:UIControlEventTouchUpInside];
	}
    [facebookCell addSubview:fbButton];
	
	[vote1Butt setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"vote1"]];
	[vote2Butt setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"vote2"]];
	[vote3Butt setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"vote3"]];
	[vote4Butt setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:@"vote4"]];
	
	

}

-(void)viewWillAppear:(BOOL)animated{
	[foursquarePassword setText:nil];
	[foursquareUsername setText:nil];
	[twitterPassword setText:nil];
	[twitterUsername setText:nil];
	if ([[KBAccountManager sharedInstance] usesFoursquare]) {
		[foursquareUsername setPlaceholder:@"logged in"];
		[foursquarePassword setPlaceholder:@" "];
	}else {
		[foursquareUsername setPlaceholder:@"4sq email/phone"];
		[foursquarePassword setPlaceholder:@"password"];
	}
	if ([[KBAccountManager sharedInstance] usesTwitter]) {
		[twitterUsername setPlaceholder:@"logged in"];
		[twitterPassword setPlaceholder:@" "];
	}else {
		[twitterUsername setPlaceholder:@"twitter name"];
		[twitterPassword setPlaceholder:@"password"];
	}

	[x4SQ setEnabled:[[KBAccountManager sharedInstance] usesFoursquare]];
	[xTW setEnabled:[[KBAccountManager sharedInstance] usesTwitter]];
	[xFB setEnabled:[[KBAccountManager sharedInstance] usesFacebook]];
	[x4SQ setHidden:![[KBAccountManager sharedInstance] usesFoursquare]];
	[xTW setHidden:![[KBAccountManager sharedInstance] usesTwitter]];
	[xFB setHidden:![[KBAccountManager sharedInstance] usesFacebook]];
	[yFB setEnabled:![[KBAccountManager sharedInstance] usesFacebook]];
	[yFB setHidden:[[KBAccountManager sharedInstance] usesFacebook]];
}
#pragma mark -
#pragma mark Facebook delegate methods

-(void)facebookLoggedIn{
	/* old
	[fbButton setImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
	[fbButton setFrame:CGRectMake(facebookCell.frame.size.width/2 - 90/2, 50, 90, 31)];
	[fbButton removeTarget:[FacebookProxy instance] action:@selector(doAuth) forControlEvents:UIControlEventTouchUpInside];
	[fbButton addTarget:[FacebookProxy instance] action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
	[[KBAccountManager sharedInstance] setUsesFacebook:YES];
	 */
	[xFB setEnabled:YES];
	[xFB setHidden:NO];
	[yFB setEnabled:NO];
	[yFB setHidden:YES];
	
}
-(void)facebookLoggedOut{
	/*old
	[fbButton setImage:[UIImage imageNamed:@"login2.png"] forState:UIControlStateNormal];
	[fbButton setFrame:CGRectMake(facebookCell.frame.size.width/2 - 176/2, 50, 176, 31)];
	[fbButton removeTarget:[FacebookProxy instance] action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
	[fbButton addTarget:[FacebookProxy instance] action:@selector(doAuth) forControlEvents:UIControlEventTouchUpInside];
	[[KBAccountManager sharedInstance] setUsesFacebook:NO];
	 */
	[xFB setEnabled:NO];
	[xFB setHidden:YES];
	[yFB setEnabled:YES];
	[yFB setHidden:NO];
	
}
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
    //[[KBAccountManager sharedInstance] setUsesFacebook:YES];
}

- (void)sessionDidLogout:(FBSession*)session {
   // [[KBAccountManager sharedInstance] setUsesFacebook:NO];
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
    // https://twitter.com/account/geo
	[self openWebView: @"https://twitter.com/account/geo"];
}

- (void) postPhotosToFacebook {
    [[KBAccountManager sharedInstance] setShouldPostPhotosToFacebook:postPhotosToFacebookSwitch.on];
}

- (void) displayWhatsThis {
    isWhatsThisDisplayed = YES;
    [theTableView reloadData];
}

- (void) nextOptionView {
    FeedbackViewController *controller = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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
	
	DLog(@"About to request an xAuth token exchange for username: ]%@[ password: ]%@[.", username, password);
	
	[[[KBTwitterManager twitterManager] twitterEngine] exchangeAccessTokenForUsername:username password:password];
}

#pragma mark XAuthTwitterEngineDelegate methods

- (void) storeCachedTwitterXAuthAccessTokenString: (NSString *)tokenString forUsername:(NSString *)username
{
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"twittername"]; //store the username
	// FIXME
	// Note: do not use NSUserDefaults to store this in a production environment. 
	// ===== Use the keychain instead. Check out SFHFKeychainUtils if you want 
	//       an easy to use library. (http://github.com/ldandersen/scifihifi-iphone) 
	//
	DLog(@"Access token string returned: %@", tokenString);
	
	[[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:kCachedXAuthAccessTokenStringKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [[KBAccountManager sharedInstance] setUsesTwitter:YES];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginNotification"
//                                                        object:nil
//                                                      userInfo:nil];
    
    [self stopProgressBar];
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded!  Your new username and password have been authenticated."];
    [self displayPopupMessage:message];
    [message release];
    
    //[self dismissModalViewControllerAnimated:YES];
}
-(void)twitterLoggedIn{
	[self stopProgressBar];
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded!  Your new username and password have been authenticated."];
    [self displayPopupMessage:message];
    [message release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate loggedInToTwitter];
	[twitterPassword setPlaceholder:@" "];
	[twitterUsername setPlaceholder:@"logged in"];
	[twitterPassword setText:nil];
	[twitterUsername setText:nil];
	[xTW setEnabled:YES];
	[xTW setHidden:NO];
}
#pragma mark delgate callbacks

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"friend response for login: %@", inString);
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
		[prefs synchronize];
        DLog(@"Stored username: %@", foursquareUsername.text);
        
        NSError *error = nil;
        [SFHFKeychainUtils storeUsername:foursquareUsername.text
                             andPassword:foursquarePassword.text
                          forServiceName:@"Kickball" 
                          updateExisting:YES error:&error];
        
        FSUser* user = [[FoursquareAPI userFromResponseXML:inString] retain];
        [self setAuthenticatedUser:user];
		//[[KBAccountManager sharedInstance] setUsesFoursquare:YES];

        // display success message and save to keychain
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Success!" andMessage:@"Authentication succeeded!  Your new username and password have been authenticated."];
        [self displayPopupMessage:message];
        [message release];
		KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
		[appDelegate loggedInToFoursquare];
		[foursquareUsername setPlaceholder:@"logged in"];
		[foursquarePassword setPlaceholder:@" "];
		[foursquarePassword setText:nil];
		[foursquareUsername setText:nil];
		[x4SQ setEnabled:YES];
		[x4SQ setHidden:NO];
    }
}

- (void) twitterXAuthConnectionDidFailWithError: (NSError *)error;
{
	DLog(@"Error: %@", error);
	
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
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 400; // !isWhatsThisDisplayed ? 229 : 355;
    } else if (indexPath.row == 1) {
        return 211;
    } else {
        return 159;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
		/*
        if (isWhatsThisDisplayed) {
            CGRect frame = whyThisImage.frame;
            frame.origin = CGPointMake(17, 220);
            whyThisImage.frame = frame;
            [foursquareCell addSubview:whyThisImage];
            
            [whatIsThisButton removeFromSuperview];
        }
        return foursquareCell;
		 */
		return uberCell;
    } else if (indexPath.row == 1) {
        return twitterCell;
    } else {
        return facebookCell;
    }
}

#pragma mark -
#pragma mark Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	if (textField==foursquareUsername) {
		if ([[KBAccountManager sharedInstance] usesFoursquare]) {
			//pop action sheet, and return NO
			[self logout4SQ];
			return NO;
		}else {
			return YES;
		}
	}else if (textField==foursquarePassword) {
		if ([[KBAccountManager sharedInstance] usesFoursquare]) {
			//pop action sheet, and return NO
			[self logout4SQ];
			return NO;
		}else {
			return YES;
		}
	}else if (textField==twitterUsername) {
		if ([[KBAccountManager sharedInstance] usesTwitter]) {
			//pop action sheet, and return NO
			[self logoutTW];
			return NO;
		}else {
			return YES;
		}
	}else if (textField==twitterPassword) {
		if ([[KBAccountManager sharedInstance] usesTwitter]) {
			//pop action sheet, and return NO
			[self logoutTW];
			return NO;
		}else {
			return YES;
		}
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //DLog(@"text field did begin editing: %@", textField);
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 0.7) {
        heightFraction = 0.7;
    }
	animatedDistance = 0;
	if(textField==twitterPassword || textField==twitterUsername){
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
			animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
		} else {
			animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
		}
	}
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    DLog(@"animated distance: %f", animatedDistance);
    DLog(@"viewframe origin y: %f", viewFrame.origin.y);
    
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
    int hideOffset = PORTRAIT_KEYBOARD_HEIGHT + hideKeyboardButt.frame.size.height - animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
//    [toolbar setFrame:toolbarFrame];
    [self.view setFrame:viewFrame];
	[keyboardMask setCenter:CGPointMake(keyboardMask.center.x, keyboardMask.center.y - hideOffset)];
	[hideKeyboardButt setCenter:CGPointMake(hideKeyboardButt.center.x, hideKeyboardButt.center.y - hideOffset)];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //DLog(@"text field did end editing: %@", textField);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    int hideOffset = PORTRAIT_KEYBOARD_HEIGHT + hideKeyboardButt.frame.size.height - animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
	[keyboardMask setCenter:CGPointMake(keyboardMask.center.x, keyboardMask.center.y + hideOffset)];
	[hideKeyboardButt setCenter:CGPointMake(hideKeyboardButt.center.x, hideKeyboardButt.center.y + hideOffset)];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField==foursquareUsername) {
		//[userName resignFirstResponder];
		[foursquarePassword becomeFirstResponder];
	}else if (textField==foursquarePassword){
		[foursquarePassword resignFirstResponder];
		[self startProgressBar:@"Logging in..."];
		[[FoursquareAPI sharedInstance] getFriendsWithTarget:foursquareUsername.text andPassword:foursquarePassword.text andTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
	}else if (textField==twitterUsername) {
		//[userName resignFirstResponder];
		[twitterPassword becomeFirstResponder];
	}else if (textField==twitterPassword) {
		[twitterPassword resignFirstResponder];
		[self startProgressBar:@"Logging in..."];
		NSString *un = twitterUsername.text;
		NSString *pw = twitterPassword.text;
		
		/*
		DLog(@"About to request an xAuth token exchange for username: ]%@[ password: ]%@[.", un, pw);
		if (self.twitterEngine==nil) {
			self.twitterEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
			self.twitterEngine.consumerKey = kOAuthConsumerKey;
			self.twitterEngine.consumerSecret = kOAuthConsumerSecret;
		}*/
		[[[KBTwitterManager twitterManager] twitterEngine] exchangeAccessTokenForUsername:un password:pw];
	}
	
    //[self cancelEditing];
    return NO;
}

-(void)pressOptionsLeft{
	[self hideKeyboard];
	NSArray *newStack = [NSArray arrayWithObjects:[(OptionsNavigationController*)self.navigationController base],[(OptionsNavigationController*)self.navigationController checkin],self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
	[[self navigationController] popViewControllerAnimated:YES];
}
-(void)pressOptionsRight{
	[self hideKeyboard];
	NSArray *newStack = [NSArray arrayWithObjects:[(OptionsNavigationController*)self.navigationController base],self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
	[[self navigationController] pushViewController:[(OptionsNavigationController*)self.navigationController friendPriority] animated:YES];
}


- (IBAction) doVote1{
	BOOL voted = [[NSUserDefaults standardUserDefaults] boolForKey:@"vote1"];
	if (!voted) {
		//go ahead and vote
		ASIFormDataRequest *feedback = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://kickball.gorlochs.com/kickball/votes"]] autorelease];
		[feedback setRequestMethod:@"POST"];
		[feedback setPostValue:@"xbox live" forKey:@"vote[voteValue]"];
		[feedback setPostValue:@"next service 1.5" forKey:@"vote[voteId]"];
		[feedback setDidFailSelector:@selector(feedbackWentWrong:)];
		[feedback setDidFinishSelector:@selector(feedbackDidFinish:)];
		[feedback setTimeOutSeconds:100];
		[feedback setDelegate:self];
		[feedback startAsynchronous];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vote1"];

	}
	//make this one selected
	[vote1Butt setSelected:YES];
}
- (IBAction) doVote2{
	BOOL voted = [[NSUserDefaults standardUserDefaults] boolForKey:@"vote2"];
	if (!voted) {
		//go ahead and vote
		ASIFormDataRequest *feedback = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://kickball.gorlochs.com/kickball/votes"]] autorelease];
		[feedback setRequestMethod:@"POST"];
		[feedback setPostValue:@"linked in" forKey:@"vote[voteValue]"];
		[feedback setPostValue:@"next service 1.5" forKey:@"vote[voteId]"];
		[feedback setDidFailSelector:@selector(feedbackWentWrong:)];
		[feedback setDidFinishSelector:@selector(feedbackDidFinish:)];
		[feedback setTimeOutSeconds:100];
		[feedback setDelegate:self];
		[feedback startAsynchronous];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vote2"];
	}
	//make this one selected
	[vote2Butt setSelected:YES];
}
- (IBAction) doVote3{
	BOOL voted = [[NSUserDefaults standardUserDefaults] boolForKey:@"vote3"];
	if (!voted) {
		//go ahead and vote
		ASIFormDataRequest *feedback = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://kickball.gorlochs.com/kickball/votes"]] autorelease];
		[feedback setRequestMethod:@"POST"];
		[feedback setPostValue:@"flickr" forKey:@"vote[voteValue]"];
		[feedback setPostValue:@"next service 1.5" forKey:@"vote[voteId]"];
		[feedback setDidFailSelector:@selector(feedbackWentWrong:)];
		[feedback setDidFinishSelector:@selector(feedbackDidFinish:)];
		[feedback setTimeOutSeconds:100];
		[feedback setDelegate:self];
		[feedback startAsynchronous];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vote3"];

	}
	//make this one selected
	[vote3Butt setSelected:YES];
}
- (IBAction) doVote4{
	BOOL voted = [[NSUserDefaults standardUserDefaults] boolForKey:@"vote4"];
	if (!voted) {
		//go ahead and vote
		ASIFormDataRequest *feedback = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://kickball.gorlochs.com/kickball/votes"]] autorelease];
		[feedback setRequestMethod:@"POST"];
		[feedback setPostValue:@"gowalla" forKey:@"vote[voteValue]"];
		[feedback setPostValue:@"next service 1.5" forKey:@"vote[voteId]"];
		[feedback setDidFailSelector:@selector(feedbackWentWrong:)];
		[feedback setDidFinishSelector:@selector(feedbackDidFinish:)];
		[feedback setTimeOutSeconds:100];
		[feedback setDelegate:self];
		[feedback startAsynchronous];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vote4"];

	}
	//make this one selected
	[vote4Butt setSelected:YES];
}

- (void) feedbackWentWrong:(ASIHTTPRequest *) request {
    DLog(@"BOOOOOOOOOOOO!");
    DLog(@"response msg: %@", request.responseStatusMessage);
}

- (void) feedbackDidFinish:(ASIHTTPRequest *) request {
    DLog(@"YAAAAAAAAAAAY!");
    DLog(@"response msg: %@", request.responseStatusMessage);
}

#pragma mark -
#pragma mark logout

- (IBAction) logout4SQ{
	if (actionSheetUp) {
		return;
	}
	actionSheetUp = YES;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Logout from Foursquare?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Yes, logout now."
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
    [actionSheet release];
}
- (IBAction) logoutFB{
	if (actionSheetUp) {
		return;
	}
	actionSheetUp = YES;
	[self hideKeyboard];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Logout from Facebook?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Yes, logout now."
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
    [actionSheet release];
	
}
- (IBAction) logoutTW{
	if (actionSheetUp) {
		return;
	}
	actionSheetUp = YES;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Logout from Twitter?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Yes, logout now."
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 3;
    [actionSheet showInView:self.view];
    [actionSheet release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	actionSheetUp = NO;
	switch (actionSheet.tag) {
		case 1:
			//foursquare
			switch (buttonIndex) {
				case 0:
					//do logout
					[[FoursquareAPI sharedInstance] logout];
					KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
					[appDelegate loggedOutOfFoursquare];
					[x4SQ setEnabled:NO];
					[x4SQ setHidden:YES];
					[foursquareUsername setPlaceholder:@"4sq email/phone"];
					[foursquarePassword setPlaceholder:@"password"];
					break;
				case 1:
					//do noting?
					break;
				default:
					break;
			}
			break;
		case 2:
			//facebook
			switch (buttonIndex) {
				case 0:
					//do logout
					[[FacebookProxy instance] logout];
					break;
				case 1:
					//do noting?
					break;
				default:
					break;
			}
			break;
		case 3:
			//twitter
			switch (buttonIndex) {
				case 0:
					//do logout
					[[[KBTwitterManager twitterManager] twitterEngine] clearAccessToken];
					[[KBTwitterManager twitterManager] clearCaches];
					KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
					[appDelegate loggedOutOfTwitter];
					[xTW setEnabled:NO];
					[xTW setHidden:YES];
					[twitterUsername setPlaceholder:@"twitter name"];
					[twitterPassword setPlaceholder:@"password"];
					break;
				case 1:
					//do noting?
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
}

- (IBAction) loginFB{
	[self hideKeyboard];
	[[FacebookProxy instance] doAuth];	
}
					 
					 
-(IBAction)hideKeyboard{
	[foursquareUsername resignFirstResponder];
	[foursquarePassword resignFirstResponder];
	[twitterUsername resignFirstResponder];
	[twitterPassword resignFirstResponder];
}

-(void)showKeyboardMask{
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
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    [super dealloc];
}


@end


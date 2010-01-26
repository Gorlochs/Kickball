//
//  LoginViewModalController.m
//  FSApi
//
//  Created by David Evans on 10/27/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "LoginViewModalController.h"
#import "KickballAppDelegate.h"

@interface LoginViewModalController (PrivateMethods)

- (void)setPasswordFromKeychain;

@end

@implementation LoginViewModalController

@synthesize usernameField, passwordField, rootController;

#pragma mark -
#pragma mark Keychain
- (void)setPasswordFromKeychain
{
	NSString *username = usernameField.text;
	NSError *error = nil;
	NSString *password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:@"Kickball" error:&error];
	NSLog(@"Password for %@: %@", username, password);
	passwordField.text = password;
}

#pragma mark -


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) viewDidLoad {
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [standardUserDefaults stringForKey:kUsernameDefaultsKey];
	if (username)
	{
		usernameField.text = username;
		[self setPasswordFromKeychain];		
	}
	[usernameField becomeFirstResponder];
    [[Beacon shared] startSubBeaconWithName:@"Login View"];
	[super viewDidLoad];
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
	if (theTextField == passwordField) {

		[passwordField resignFirstResponder];
		[self login:theTextField];
        // Invoke the method that changes the greeting.
	} else if (theTextField == usernameField) {
		[passwordField becomeFirstResponder];
		// Invoke the method that changes the greeting.
		
	}
	return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
	if (textField == passwordField && (passwordField.text.length == 0))
	{
		//look up password after empty password field takes focus
		//[self setPasswordFromKeychain];
	}
}

- (IBAction) login: (id) sender {
    [self startProgressBar:@"Retrieving new username and password..."];
    [[FoursquareAPI sharedInstance] getFriendsWithTarget:usernameField.text andPassword:passwordField.text andTarget:self andAction:@selector(friendResponseReceived:withResponseString:)];
}

- (void)friendResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"friend response for login: %@", inString);
    [self stopProgressBar];
    // cheap way of checking for successful authentication
    BOOL containsUnauthorized = [inString rangeOfString:@"unauthorized" options:NSCaseInsensitiveSearch].length > 0;
    if (containsUnauthorized) {
        // display fail message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Authentication" andSubtitle:@"Failed" andMessage:@"Please try again."];
        [self displayPopupMessage:message];
        [message release];
    } else {
        [[Beacon shared] startSubBeaconWithName:@"Logging in"];
        NSString *username = usernameField.text;
        NSString *password = passwordField.text;
        [[FoursquareAPI sharedInstance] doLoginUsername: username andPass:password];	
        
        if (username)
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:username forKey:kUsernameDefaultsKey];
            
            NSLog(@"Stored username: %@", username);
        }
        
        NSError *error = nil;
        [SFHFKeychainUtils storeUsername:username
                             andPassword:password
                          forServiceName:@"Kickball" 
                          updateExisting:YES error:&error];
        
        KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate setupAuthenticatedUserAndPushNotifications];
        
        if([self.rootController respondsToSelector:@selector(doInitialDisplay)]){
            [(KBBaseViewController *)self.rootController doInitialDisplay];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"signInComplete"
                                                            object:nil
                                                          userInfo:nil];
        [self dismissModalViewControllerAnimated:true];
//        // display success message and save to keychain
//        KBMessage *message = [[KBMessage alloc] initWithMember:@"Authentication" andSubtitle:@"Success" andMessage:@"Your new username and password have been authenticated."];
//        [self displayPopupMessage:message];
//        [message release];
//        
//        [[FoursquareAPI sharedInstance] doLoginUsername: username.text andPass:password.text];	
//        
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs setObject:username forKey:kUsernameDefaultsKey];
//        NSLog(@"Stored username: %@", username.text);
//        
//        NSError *error = nil;
//        [SFHFKeychainUtils storeUsername:username.text
//                             andPassword:password.text
//                          forServiceName:@"Kickball" 
//                          updateExisting:YES error:&error];
    }
}

- (IBAction) openFoursquareForgottenPasswordWebPage {
    [[Beacon shared] startSubBeaconWithName:@"Exiting for Forgotten Password"];
    NSURL *url = [NSURL URLWithString:@"http://foursquare.com/change_password"];
    
    if (![[UIApplication sharedApplication] openURL:url])  {
        NSLog(@"Failed to open url: %@" ,[url description]);
    }
//    ForgotPasswordWebViewController *fpwvc = [[ForgotPasswordWebViewController alloc] initWithNibName:@"ForgotPasswordWebViewController" bundle:nil];
//    UIWebView *webView = [[UIWebView alloc] init];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://foursquare.com/change_password"]];
//    [webView loadRequest:request];
//    fpwvc.webView = webView;
//    [request release];
//    [webView release];
//    [self.navigationController presentModalViewController:fpwvc animated:YES];
}

- (void)dealloc {
    [usernameField release];
    [passwordField release];
    [rootController release];
    [forgottenPasswordButton release];
    [super dealloc];
}


@end

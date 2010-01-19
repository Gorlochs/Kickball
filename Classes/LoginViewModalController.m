//
//  LoginViewModalController.m
//  FSApi
//
//  Created by David Evans on 10/27/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "LoginViewModalController.h"
#import "ForgotPasswordWebViewController.h"
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

- (IBAction) login: (id) sender
{
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
}

- (IBAction) openFoursquareForgottenPasswordWebPage {
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

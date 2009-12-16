//
//  LoginViewModalController.m
//  FSApi
//
//  Created by David Evans on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoginViewModalController.h"

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
	NSError *error;
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
	
	if([self.rootController respondsToSelector:@selector(doInitialDisplay)]){
		[(KBBaseViewController *)self.rootController doInitialDisplay];
	}
	[self dismissModalViewControllerAnimated:true];
}

- (void)dealloc {
    [usernameField release];
    [passwordField release];
    [rootController release];
    [super dealloc];
}


@end

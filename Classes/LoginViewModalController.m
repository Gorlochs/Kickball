//
//  LoginViewModalController.m
//  FSApi
//
//  Created by David Evans on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoginViewModalController.h"

@implementation LoginViewModalController

@synthesize usernameField, passwordField, rootController;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	// When the user presses return, take focus away from the text field so that the keyboard is dismissed.
	if (theTextField == passwordField) {
		[passwordField resignFirstResponder];
        // Invoke the method that changes the greeting.
	} else {
		if (theTextField == usernameField) {
			[usernameField resignFirstResponder];
			// Invoke the method that changes the greeting.
		}
	}
	return YES;
}

- (IBAction) login: (id) sender
{
	[[FoursquareAPI sharedInstance] doLoginUsername:[usernameField text] andPass:[passwordField text]];	
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

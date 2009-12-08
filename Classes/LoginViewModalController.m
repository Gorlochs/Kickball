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

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}


@end

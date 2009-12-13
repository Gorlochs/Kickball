//
//  KBBaseViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KBBaseViewController.h"
#import "KickballAppDelegate.h"
#import "ProfileViewController.h"
#import "FoursquareAPI.h"
#import "Utilities.h"

@implementation KBBaseViewController

@synthesize loginViewModal;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    FSUser *tmpUser = [self getAuthenticatedUser];
    if (tmpUser != nil) {
        signedInUserIcon.imageView.image = [[Utilities sharedInstance] getCachedImage:tmpUser.photo];
        NSLog(@"icon being retrieved and displayed: %@", signedInUserIcon.imageView.image);
        signedInUserIcon.hidden = NO;
    }
}

- (void) backOneView {
    NSLog(@"backOneView is being called");
    //    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewUserProfile {
    // take user to their profile
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    pvc.userId = [self getAuthenticatedUser].userId;
    [self.navigationController pushViewController:pvc animated:YES];
    [pvc release];
}

- (FSUser*) getAuthenticatedUser {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.user;
}

// ugh. this sucks. it works for now, but it's yet another thing that needs to be fixed
// TODO: set the user object in the FoursquareAPI instead of using the appdelegate
- (void) setAuthenticatedUser:(FSUser*)user {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.user = user;
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


- (void)dealloc {
    [signedInUserIcon release];
    [progressViewController release];
    [loginViewModal release];
    [super dealloc];
}

- (void)doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass{
    
	[[FoursquareAPI sharedInstance] doLoginUsername:fsUser andPass:fsPass];
	[self dismissModalViewControllerAnimated:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
    
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
	[self dismissModalViewControllerAnimated:YES];
}

- (void) startProgressBar:(NSString*)textToDisplay {
    if (textToDisplay == nil) {
        textToDisplay = @"Connecting...";
    }
    progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressView" bundle:nil];
    [self.view addSubview:progressViewController.view];
    progressViewController.activityLabel.text = textToDisplay;
    [progressViewController.activityLabel setShadowColor:[UIColor blackColor]];
    [progressViewController.activityLabel setShadowOffset:CGSizeMake(1, 1)];
}

- (void) stopProgressBar {
    [progressViewController.view removeFromSuperview];
}

- (void) doInitialDisplay {
}

@end

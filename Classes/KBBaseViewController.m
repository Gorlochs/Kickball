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

@implementation KBBaseViewController

@synthesize loginViewModal;

- (void) viewDidLoad {
    [super viewDidLoad];
    
//    authenticatedUser = [self getAuthenticatedUser];
//    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:authenticatedUser.photo]];
//    UIImage *img = [[UIImage alloc] initWithData:data];
//    //UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
//    //UIImage *image = [UIImage imageWithData:data];
//    authUserIcon.imageView.image = img;
//    [img release];
//    NSLog(@"image: %@", authUserIcon.imageView.image);
}

- (void) backOneView {
    NSLog(@"backOneView is being called");
    //    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) viewUserProfile {
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
    [super dealloc];
}

- (void)doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass{
    
	[[FoursquareAPI sharedInstance] doLoginUsername:fsUser andPass:fsPass];
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
}

- (void) stopProgressBar {
    [progressViewController.view removeFromSuperview];
}

- (void) doInitialDisplay {
}

@end

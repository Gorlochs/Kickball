//
//  KBBaseViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/17/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KBBaseViewController.h"
#import "KickballAppDelegate.h"
#import "ProfileViewController.h"
#import "FoursquareAPI.h"
#import "Utilities.h"
#import "SettingsViewController.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "KBWebViewController.h"

@implementation KBBaseViewController

@synthesize loginViewModal;
@synthesize textViewReturnValue;

- (void) viewDidLoad {
    [super viewDidLoad];
    [UIView setAnimationsEnabled:YES];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasViewedInstructions = [standardUserDefaults boolForKey:@"viewedInstructions"];
    
    if (hasViewedInstructions) {
        FSUser *tmpUser = [self getAuthenticatedUser];
        [self setUserIconView:tmpUser];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayShoutMessage:) name:@"shoutSent" object:nil];
    
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.pushNotificationUserId addObserver:self forKeyPath:@"pushUserId" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"observed value change");
    if ([keyPath isEqualToString:@"pushUserId"] ) {
        NSLog(@"observed value changed for pushnotification venueid");
        KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
        if (appDelegate.pushNotificationUserId != nil) {
            [self displayPushedVenueId];
        }
    }    
}

- (void) displayPushedVenueId {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    PlaceDetailViewController *placeController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    placeController.venueId = appDelegate.pushNotificationUserId;
    appDelegate.pushNotificationUserId = nil;
    [self.navigationController pushViewController:placeController animated:YES];
    [placeController release];
}

- (void) setUserIconView:(FSUser*)user {
    if (user) {
        NSLog(@"user is not null");
        UIImage *image = [[Utilities sharedInstance] getCachedImage:user.photo];
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285, 3, 32, 32)];
        iconImageView.image = image;
        [image release];
        [self.view addSubview:iconImageView];
        iconImageView.layer.masksToBounds = YES;
        iconImageView.layer.cornerRadius = 4.0;
        [self.view bringSubviewToFront:signedInUserIcon];
    }
}

- (void) displayShoutMessage:(NSNotification *)inNotification {
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andSubtitle:@"Your shout was sent" andMessage:@"Thank you."];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void) backOneView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) goToHomeView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) viewUserProfile {
    // take user to their profile
    [[Beacon shared] startSubBeaconWithName:@"View User Profile from Top Nav Icon"];
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    pvc.userId = [self getAuthenticatedUser].userId;
    [self.navigationController pushViewController:pvc animated:YES];
    [pvc release];
}

- (FSUser*) getAuthenticatedUser {
    return [[FoursquareAPI sharedInstance] currentUser];
}

- (void) setAuthenticatedUser:(FSUser*)user {
    [[FoursquareAPI sharedInstance] setCurrentUser:user];
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
    [popupView release];
    [textViewController release];
    [textViewReturnValue release];
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
        textToDisplay = @"Processing...";
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

- (void) displayPopupMessage:(KBMessage*)message {
    
    popupView = [[PopupMessageView alloc] initWithNibName:@"PopupMessageView" bundle:nil];
    popupView.message = message;
    popupView.view.alpha = 0;
    [self.view addSubview:popupView.view];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    popupView.view.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) viewSettings {
    SettingsViewController *settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsController animated:YES];
    [settingsController release];
}

- (void) addHeaderAndFooter:(UITableView*)tableView {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    v.backgroundColor = [UIColor clearColor];
    //[tableView setTableHeaderView:v];
    [tableView setTableFooterView:v];
    [v release];
}

- (void) displayTextView {
    textViewController = [[KBTextViewController alloc] initWithNibName:@"KBTextViewController" bundle:nil];
    [self presentModalViewController:textViewController animated:YES];
}

- (void) checkin {
    PlacesListViewController *placesListController = [[PlacesListViewController alloc] initWithNibName:@"PlacesListViewController" bundle:nil];
    [self.navigationController pushViewController:placesListController animated:YES];
    [placesListController release];
}

- (void) openWebView:(NSString*)url {
    [[Beacon shared] startSubBeaconWithName:@"Opening link from Twitter feed"];
    KBWebViewController *webController = [[KBWebViewController alloc] initWithNibName:@"KBWebViewController" bundle:nil];
    webController.urlString = url;
    [self presentModalViewController:webController animated:YES];
    [webController release];
}

- (void) dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

@end

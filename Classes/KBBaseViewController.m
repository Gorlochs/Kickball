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
#import "UserProfileViewController.h"
#import "FoursquareAPI.h"
#import "SettingsViewController.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "KBWebViewController.h"
#import "KBTextViewController.h"
#import "ASIFormDataRequest.h"

#import "FoursquareHeaderView.h"

#define PROGRESS_BAR_TIMER_LENGTH 30.0

const NSString *kickballDomain = @"http://gorlochs.literalshore.com/kickball";
//const NSString *kickballDomain = @"http://kickball.gorlochs.com/kickball";

//@interface KBBaseViewController (Protected)
//
//- (void)dataSourceDidFinishLoadingNewData;
//
//@end

@implementation KBBaseViewController

@synthesize theTableView;
@synthesize loginViewModal;
@synthesize textViewReturnValue;
@synthesize hideHeader;
@synthesize hideFooter;
@synthesize hideRefresh;
@synthesize reloading=_reloading;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [UIView setAnimationsEnabled:YES];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasViewedInstructions = [standardUserDefaults boolForKey:@"viewedInstructions"];

//    v1.1
//    if (hasViewedInstructions) {
        FSUser *tmpUser = [self getAuthenticatedUser];
        [self setUserIconView:tmpUser];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayShoutMessage:) name:@"shoutSent" object:nil];
    
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.pushNotificationUserId addObserver:self forKeyPath:@"pushUserId" options:0 context:nil];
    
    
    // v1.1
    if (!self.hideHeader) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"FoursquareHeaderView" owner:self options:nil];
        FoursquareHeaderView *headerView = [nibViews objectAtIndex:0];
        [self.view addSubview:headerView];
    }
    if (!self.hideFooter) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"FooterTabView" owner:self options:nil];
        footerTabView = [nibViews objectAtIndex:0];
        footerTabView.frame = CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40);
        [self.view addSubview:footerTabView];
    }
    
	if (refreshHeaderView == nil && !self.hideRefresh) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.theTableView.bounds.size.height, 320.0f, self.theTableView.bounds.size.height)];
		refreshHeaderView.backgroundColor = [UIColor colorWithRed:176.0/255.0 green:36.0/255.0 blue:44.0/255.0 alpha:1.0];
		[self.theTableView addSubview:refreshHeaderView];
		self.theTableView.showsVerticalScrollIndicator = YES;
		[refreshHeaderView release];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    // this is to clean up some stuff that gets set by the photo viewer
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

- (void) viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"shoutSent"];
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.pushNotificationUserId removeObserver:self forKeyPath:@"pushUserId"];
	refreshHeaderView=nil;
    [super viewDidUnload];
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
    PlaceDetailViewController *placeController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView_v2" bundle:nil];
    placeController.venueId = appDelegate.pushNotificationUserId;
    appDelegate.pushNotificationUserId = nil;
    [self.navigationController pushViewController:placeController animated:YES];
    [placeController release];
}

- (void) setUserIconView:(FSUser*)user {
    if (user) {
        NSLog(@"user is not null");

        CGRect frame = CGRectMake(136, 0, 46, 41);
        TTImageView *ttImage = [[TTImageView alloc] initWithFrame:frame];
        ttImage.urlPath = user.photo;
        ttImage.clipsToBounds = YES;
        ttImage.contentMode = UIViewContentModeScaleToFill;
        [footerTabView addSubview:ttImage];
        
        UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        button.frame = frame;
        button.showsTouchWhenHighlighted = YES;
        [button addTarget:self action:@selector(displayProfile:) forControlEvents:UIControlEventTouchUpInside]; 
        [footerTabView addSubview:button];
        [button release];
        [ttImage release];
        
//        TTButton *imageButton = [TTButton buttonWithStyle:@"blockPhoto:"]; 
//        imageButton.frame = CGRectMake(136, 0, 46, 41);
//        imageButton.backgroundColor = [UIColor greenColor];
//        [imageButton setImage:user.photo forState:UIControlStateNormal];
//        [footerTabView addSubview:imageButton];
        
//        UIImage *image = [[Utilities sharedInstance] getCachedImage:user.photo];
//        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(278, 2, 42, 42)];
//        iconImageView.image = image;
//        [image release];
//        [self.view addSubview:iconImageView];
//        iconImageView.layer.masksToBounds = YES;
//        iconImageView.layer.cornerRadius = 4.0;
//        [self.view bringSubviewToFront:signedInUserIcon];
    }
}

- (void) displayProfile:(id)sender {
    
}

- (void) displayShoutMessage:(NSNotification *)inNotification {
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your shout was sent."];
    [self displayPopupMessage:msg];
    [msg release];
}

- (void) viewUserProfile {
    // take user to their profile
    [[Beacon shared] startSubBeaconWithName:@"View User Profile from Top Nav Icon"];
    ProfileViewController *pvc = [[ProfileViewController alloc] initWithNibName:@"ProfileView_v2" bundle:nil];
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

- (void)dealloc {
    [signedInUserIcon release];
    [progressViewController release];
    [loginViewModal release];
    [popupView release];
    [textViewReturnValue release];
//    [iconImageView release];  // uncommenting this crashes shit. not sure why.
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

- (void) startProgressBar:(NSString*)textToDisplay withTimer:(BOOL)shouldSetTimer {
    if (textToDisplay == nil) {
        textToDisplay = @"Processing...";
    }
    progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressView" bundle:nil];
    [self.view addSubview:progressViewController.view];
    progressViewController.activityLabel.text = textToDisplay;
    [progressViewController.activityLabel setShadowColor:[UIColor blackColor]];
    [progressViewController.activityLabel setShadowOffset:CGSizeMake(1, 1)];
    
    if (shouldSetTimer) {
        progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:PROGRESS_BAR_TIMER_LENGTH target:self selector:@selector(stopProgressBarAndDisplayErrorMessage:) userInfo:nil repeats:NO];        
    }
}

- (void) startProgressBar:(NSString*)textToDisplay {
    [self startProgressBar:textToDisplay withTimer:YES];
}

-(void) stopProgressBarAndDisplayErrorMessage:(NSTimer*)theTimer {
        [self stopProgressBar];
        
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Foursquare is not currently responding. Please try again shortly."];
        [self displayPopupMessage:message];
        [message release];
}

- (void) stopProgressBar {
    [progressBarTimer invalidate];
    progressBarTimer = nil;
    [progressViewController.view removeFromSuperview];
}

- (void) doInitialDisplay {
}

- (void) displayPopupMessage:(KBMessage*)message {
    
    [self stopProgressBar];
    popupView = [[PopupMessageView alloc] initWithNibName:@"PopupMessageView" bundle:nil];
    popupView.message = message;
    popupView.view.alpha = 0;
    //    popupView.view.layer.cornerRadius = 8.0;
    [self.view addSubview:popupView.view];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    popupView.view.alpha = 1.0;
    
    [UIView commitAnimations];
    //[self performSelector:@selector(fadePopupMessage) withObject:nil afterDelay:3];
}

- (void) displayPopupMessageForLogin:(KBMessage*)message {
    
    [self stopProgressBar];
    popupView = [[PopupMessageView alloc] initWithNibName:@"PopupMessageView" bundle:nil];
    popupView.message = message;
    popupView.view.alpha = 0;
    //    popupView.view.layer.cornerRadius = 8.0;
    [self.view addSubview:popupView.view];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    popupView.view.alpha = 1.0;
    popupView.view.frame = CGRectMake(0, -212, popupView.view.frame.size.width, popupView.view.frame.size.height);
    [UIView commitAnimations];
    //[self performSelector:@selector(fadePopupMessage) withObject:nil afterDelay:3];
}

- (void) fadePopupMessage {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    popupView.view.alpha = 0.0;
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

- (void) openWebView:(NSString*)url {
    [[Beacon shared] startSubBeaconWithName:@"Opening link from Twitter feed"];
    KBWebViewController *webController = [[KBWebViewController alloc] initWithNibName:@"KBWebViewController" bundle:nil];
    NSLog(@"website url: %@", url);
    webController.urlString = url;
    [self presentModalViewController:webController animated:YES];
    [webController release];
}

- (void) displayTextView {
    KBTextViewController *textViewController = [[KBTextViewController alloc] initWithNibName:@"KBTextViewController" bundle:nil];
    [self presentModalViewController:textViewController animated:YES];
    [textViewController release];
}

- (void) displayTextViewForCheckin {
    KBTextViewController *textViewController = [[KBTextViewController alloc] initWithNibName:@"KBTextViewController" bundle:nil];
    textViewController.isCheckin = YES;
    [self presentModalViewController:textViewController animated:YES];
    [textViewController release];
}

- (void) dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) displayFoursquareErrorMessage:(NSString*)errorMessage {
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Foursquare Error" andMessage:errorMessage];
    [self displayPopupMessage:message];
    [message release];
}

// EGO class

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload
	//  put here just for demo
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (void) refreshTable {
    
    NSLog(@"^^^^^ you should not be in here! ^^^^^^^^");
	[self dataSourceDidFinishLoadingNewData];
}


- (void) doneLoadingTableViewData {
	//  model should call this when its done loading
    [self refreshTable];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (scrollView.isDragging) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading) {
        _reloading = YES;
        [self reloadTableViewDataSource];
        [refreshHeaderView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.theTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
	}
}

- (void) dataSourceDidFinishLoadingNewData {
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.theTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[refreshHeaderView setState:EGOOPullRefreshNormal];
	//[refreshHeaderView setCurrentDate];  //  should check if data reload was successful 
}

- (void) displayProperProfileView:(NSString*)userId {
    if ([userId isEqualToString:[self getAuthenticatedUser].userId]) {
        UserProfileViewController *profileController = [[UserProfileViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
        profileController.userId = userId;
        [self.navigationController pushViewController:profileController animated:YES];
        [profileController release];
    } else {
        ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView_v2" bundle:nil];
        profileController.userId = userId;
        [self.navigationController pushViewController:profileController animated:YES];
        [profileController release];        
    }
}

@end

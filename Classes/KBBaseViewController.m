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
#import "OptionsViewController.h"
#import "PlaceDetailViewController.h"
#import "PlacesListViewController.h"
#import "KBWebViewController.h"
#import "KBShoutViewController.h"
#import "ASIFormDataRequest.h"
#import "KBAccountManager.h"


#define PROGRESS_BAR_TIMER_LENGTH 30.0

const NSString *kickballDomain = @"http://gorlochs.literalshore.com/kickball";
//const NSString *kickballDomain = @"http://kickball.gorlochs.com/kickball";

@interface KBBaseViewController (Private)

- (void) setTabImages;
- (void) hideAppropriateTabs;

@end


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
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayShoutMessage:) name:@"shoutSent" object:nil];
    
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.pushNotificationUserId addObserver:self forKeyPath:@"pushUserId" options:0 context:nil];
    
    // v1.1
//    if (!self.hideHeader && headerNibName) {
//        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:headerNibName owner:self options:nil];
//        FoursquareHeaderView *headerView = [nibViews objectAtIndex:0];
//        [self.view addSubview:headerView];
//    }
    if (!self.hideFooter) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"FooterTabView" owner:self options:nil];
        footerTabView = [nibViews objectAtIndex:0];
        footerTabView.frame = CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40);
        
        [self setTabImages];
        
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

- (void) setTabImages {
    [signedInUserIcon setImage:[[Utilities sharedInstance] getCachedImage:[self getAuthenticatedUser].photo] forState:UIControlStateNormal];
    switch (footerType) {
        case KBFooterTypeProfile:
            break;
        case KBFooterTypeFacebook:
            [foursquareTab setImage:[UIImage imageNamed:@"kbTab04.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"twitTab03.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"fbTab01.png"] forState:UIControlStateNormal];
            break;
        case KBFooterTypeTwitter:
            [foursquareTab setImage:[UIImage imageNamed:@"kbTab03.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"twitTab01.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"fbTab04.png"] forState:UIControlStateNormal];
            break;
        case KBFooterTypeFoursquare:
            [foursquareTab setImage:[UIImage imageNamed:@"kbTab01.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"twitTab04.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"fbTab03.png"] forState:UIControlStateNormal];
            break;
        default:
            [foursquareTab setImage:[UIImage imageNamed:@"kbTab01.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"twitTab04.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"fbTab03.png"] forState:UIControlStateNormal];
    }
}

// ugly ugly ugly. this was much nicer, but due to crazy architecture, I had to explicitly declare the exact position of each tab button
- (void) hideAppropriateTabs {
    if (![[KBAccountManager sharedInstance] usesTwitter] && ![[KBAccountManager sharedInstance] usesFacebook]) {
        facebookTab.hidden = YES;
        twitterTab.hidden = YES;
        
        CGRect frame = signedInUserIcon.frame;
        frame.origin = CGPointMake(228, signedInUserIcon.frame.origin.y);
        signedInUserIcon.frame = frame;
    } else if (![[KBAccountManager sharedInstance] usesTwitter]) {
        twitterTab.hidden = YES;
        
        CGRect frame = facebookTab.frame;
        frame.origin = CGPointMake(228, facebookTab.frame.origin.y);
        facebookTab.frame = frame;
        
        CGRect frame2 = signedInUserIcon.frame;
        frame2.origin = CGPointMake(182, signedInUserIcon.frame.origin.y);
        signedInUserIcon.frame = frame2;
    } else if (![[KBAccountManager sharedInstance] usesFacebook]) {
        facebookTab.hidden = YES;
        
        CGRect frame = twitterTab.frame;
        frame.origin = CGPointMake(228, twitterTab.frame.origin.y);
        twitterTab.frame = frame;
        
        CGRect frame2 = signedInUserIcon.frame;
        frame2.origin = CGPointMake(182, signedInUserIcon.frame.origin.y);
        signedInUserIcon.frame = frame2;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // this is to clean up some stuff that gets set by the photo viewer
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [self hideAppropriateTabs];
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
    UserProfileViewController *pvc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
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
    [theTableView release];
    [progressViewController release];
    [loginViewModal release];
    [popupView release];
    [textViewReturnValue release];
    [progressBarTimer release];
    
    [refreshHeaderView release];
    [footerTabView release];
    [optionsTab release];
    [facebookTab release];
    [twitterTab release];
    [foursquareTab release];
    [signedInUserIcon release];
    
    [headerNibName release];
    
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
    [progressViewController.activityLabel setShadowColor:[UIColor whiteColor]];
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

- (void) displayPopupMessageWithFadeout:(KBMessage*)message {
    [self displayPopupMessage:message];
    [self performSelector:@selector(fadePopupMessage) withObject:nil afterDelay:3];
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
    
    CGRect frame = popupView.closeButton.frame;
    frame.origin = CGPointMake(frame.origin.x, 220);
    popupView.closeButton.frame = frame;
    
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
    OptionsViewController *optionsController = [[OptionsViewController alloc] initWithNibName:@"OptionsView_v2" bundle:nil];
    [self.navigationController pushViewController:optionsController animated:YES];
    [optionsController release];
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
    KBShoutViewController *textViewController = [[KBShoutViewController alloc] initWithNibName:@"ShoutViewController" bundle:nil];
    [self presentModalViewController:textViewController animated:YES];
    [textViewController release];
}

- (void) displayTextViewForCheckin {
    KBShoutViewController *textViewController = [[KBShoutViewController alloc] initWithNibName:@"ShoutViewController" bundle:nil];
    textViewController.isCheckin = YES;
    [self presentModalViewController:textViewController animated:YES];
    [textViewController release];
}

- (void) dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) displayFoursquareErrorMessage:(NSString*)errorMessage {
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Foursquare Error" andMessage:errorMessage isError:YES];
    [self displayPopupMessage:message];
    [message release];
}

#pragma mark -
#pragma mark Pull down to refresh methods

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
	
	if (scrollView.isDragging && !self.hideRefresh) {
		if (refreshHeaderView.state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshNormal];
		} else if (refreshHeaderView.state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_reloading) {
			[refreshHeaderView setState:EGOOPullRefreshPulling];
		}
	}
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (scrollView.contentOffset.y <= - 65.0f && !_reloading && !self.hideRefresh) {
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

#pragma mark -
#pragma mark utility methods

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

#pragma mark -
#pragma mark navigation controller switching methods

- (void) switchToTwitter {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToTwitter];
}

- (void) switchToFoursquare {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToFoursquare];
}

- (void) switchToFacebook {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate switchToFacebook];
}

@end

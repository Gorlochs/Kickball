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
#import "FacebookProxy.h"
#import "KBDialogueManager.h"


#define PROGRESS_BAR_TIMER_LENGTH 30.0

//const NSString *kickballDomain = @"http://gorlochs.literalshore.com/kickball";
const NSString *kickballDomain = @"http://kickball.gorlochs.com/kickball";

@interface KBBaseViewController (Private)

- (void) setTabImages;

@end


@implementation KBBaseViewController

@synthesize theTableView;
@synthesize loginViewModal;
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
    [signedInUserIcon setAdjustsImageWhenDisabled:NO];
    if (!self.hideHeader) {
        NSArray *nibViews = nil;
		if (appDelegate.navControllerType == KBNavControllerTypeFoursquare) {
			nibViews =  [[NSBundle mainBundle] loadNibNamed:HEADER_NIB_FOURSQUARE owner:self options:nil];
		} else if (appDelegate.navControllerType == KBNavControllerTypeTwitter) {
			nibViews =  [[NSBundle mainBundle] loadNibNamed:HEADER_NIB_TWITTER owner:self options:nil];
		} else if (appDelegate.navControllerType == KBNavControllerTypeFacebook) {
			nibViews =  [[NSBundle mainBundle] loadNibNamed:HEADER_NIB_FACEBOOK owner:self options:nil];
        }
        if (nibViews) {
            headerView = (FoursquareHeaderView*)[nibViews objectAtIndex:0];
            [self.view addSubview:headerView];   
        }
    }
	
    if (!self.hideFooter) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"FooterTabView" owner:self options:nil];
        footerTabView = [nibViews objectAtIndex:0];
        footerTabView.frame = CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40);
        
        [self setTabImages];
        
        [self.view addSubview:footerTabView];
    }
	if (refreshHeaderView == nil && !self.hideRefresh) {
		refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.theTableView.bounds.size.height, 320.0f, self.theTableView.bounds.size.height)];
		[self.theTableView addSubview:refreshHeaderView];
		self.theTableView.showsVerticalScrollIndicator = YES;
	}
}

- (void) setTabImages {
    [signedInUserIcon setImage:[[Utilities sharedInstance] getCachedImage:[self getAuthenticatedUser].photo] forState:UIControlStateNormal];
	[signedInUserIcon setEnabled:YES];
	switch (footerType) {
        case KBFooterTypeProfile:
            break;
        case KBFooterTypeFacebook:
            [foursquareTab setImage:[UIImage imageNamed:@"kbTab04.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"twitTab03.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"fbTab01.png"] forState:UIControlStateNormal];
			if ([FacebookProxy instance].profilePic) {
				DLog(@"[FacebookProxy instance].profilePic class: %@", [[FacebookProxy instance].profilePic class]);
				DLog(@"[FacebookProxy instance].profilePic: %@", [FacebookProxy instance].profilePic);
				[signedInUserIcon setImage:[FacebookProxy instance].profilePic forState:UIControlStateNormal];
			} else {
				GraphAPI *graph = [[FacebookProxy instance] newGraph];
				[FacebookProxy instance].profilePic = [graph getProfilePhotoForObject:@"me"];
				[graph release];
				[signedInUserIcon setImage:[FacebookProxy instance].profilePic forState:UIControlStateNormal];
			}
			[signedInUserIcon setAdjustsImageWhenDisabled:NO];
			[signedInUserIcon setEnabled:NO];
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

- (void)viewWillAppear:(BOOL)animated {
    // this is to clean up some stuff that gets set by the photo viewer
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}

- (void) viewDidUnload {
    KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.pushNotificationUserId removeObserver:self forKeyPath:@"pushUserId"];
    [super viewDidUnload];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    DLog(@"observed value change");
    if ([keyPath isEqualToString:@"pushUserId"] ) {
        DLog(@"observed value changed for pushnotification venueid");
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
        DLog(@"user is not null");

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
    [FlurryAPI logEvent:@"View User Profile from Top Nav Icon"];
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
    if (progressViewController) [progressViewController release];
    [loginViewModal release];
    if (popupView) [popupView release];
    
    if (refreshHeaderView) [refreshHeaderView release];
    //[footerTabView release];
//    [optionsTab release];
//    [facebookTab release];
//    [twitterTab release];
//    [foursquareTab release];
//    [signedInUserIcon release];
    
    //[profileController release];
    
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
//	if (progressViewController) [progressViewController release];
	if (!progressViewController) {
		progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressView" bundle:nil];
	}
	CGRect frame = progressViewController.view.frame;
	frame.origin.y = frame.origin.y + 50;
	progressViewController.view.frame = frame;
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	progressViewController.view.frame = CGRectMake(0, 
												   progressViewController.view.frame.origin.y - 50, 
												   progressViewController.view.frame.size.width, 
												   progressViewController.view.frame.size.height);
    
    [UIView commitAnimations];
	
//    progressViewController.activityLabel.text = textToDisplay;
//    [progressViewController.activityLabel setShadowColor:[UIColor whiteColor]];
//    [progressViewController.activityLabel setShadowOffset:CGSizeMake(1, 1)];
    [self.view addSubview:progressViewController.view];
    
    if (shouldSetTimer) {
        progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:PROGRESS_BAR_TIMER_LENGTH target:self selector:@selector(stopProgressBarAndDisplayErrorMessage:) userInfo:nil repeats:NO];        
    }
}

- (void) startProgressBar:(NSString*)textToDisplay {
    [self startProgressBar:textToDisplay withTimer:YES];
}

-(void) stopProgressBarAndDisplayErrorMessage:(NSTimer*)theTimer {
    [self stopProgressBar];
    
	// FIXME: change the message so it reports either Foursquare or Twitter
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"The server is not currently responding. Please try again shortly."];
    [self displayPopupMessage:message];
    [message release];
}

- (void) stopProgressBar {
    [progressBarTimer invalidate];
    progressBarTimer = nil;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	progressViewController.view.frame = CGRectMake(0, 
												   progressViewController.view.frame.origin.y + 50, 
												   progressViewController.view.frame.size.width, 
												   progressViewController.view.frame.size.height);
	
	[UIView commitAnimations];
}

- (void) doInitialDisplay {
}

- (void) displayPopupMessage:(KBMessage*)message {
    
    [self stopProgressBar];
	
	[[KBDialogueManager sharedInstance] displayMessage:message];
	
    //if (popupView) [popupView release];
    //popupView = [[PopupMessageView alloc] initWithNibName:@"PopupMessageView" bundle:nil];
    //popupView.message = message;
	//popupView.view.frame = CGRectMake(0, 0, 320, 460);
    //popupView.view.alpha = 0;
    //    popupView.view.layer.cornerRadius = 8.0;
    //[self.navigationController.view.superview addSubview:popupView.view];
    
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationBeginsFromCurrentState:YES];
    //[UIView setAnimationDuration:0.7];
    //popupView.view.alpha = 1.0;
    
    //[UIView commitAnimations];
    //[self performSelector:@selector(fadePopupMessage) withObject:nil afterDelay:3];
}

- (void) displayPopupMessageWithFadeout:(KBMessage*)message {
    //[self displayPopupMessage:message];
    //[self performSelector:@selector(fadePopupMessage) withObject:nil afterDelay:3];
	[[KBDialogueManager sharedInstance] displayMessageWithAutoFade:message];
}

- (void) displayPopupMessageForLogin:(KBMessage*)message {
    
    [self stopProgressBar];
	[self displayPopupMessage:message];
	/*
    if (popupView) [popupView release];
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
	 */
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
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate flipToOptions];
    //OptionsViewController *optionsController = [[OptionsViewController alloc] initWithNibName:@"OptionsView_v2" bundle:nil];
    //[self.navigationController pushViewController:optionsController animated:YES];
    //[optionsController release];
}

- (void) addHeaderAndFooter:(UITableView*)tableView {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    v.backgroundColor = [UIColor clearColor];
    //[tableView setTableHeaderView:v];
    [tableView setTableFooterView:v];
    [v release];
}

- (void) openWebView:(NSString*)url {
    [FlurryAPI logEvent:@"Opening link from Twitter feed"];
    KBWebViewController *webController = [[KBWebViewController alloc] initWithNibName:@"KBWebViewController" bundle:nil andUrlString:url];
    DLog(@"website url: %@", url);
    //webController.urlString = url;
    [self presentModalViewController:webController animated:YES];
    // FIXME: commenting out below probably fixes the crash, but it's masking the REAL problem, which I need to find
    //[webController release];
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
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.1];
}

- (void) refreshTable {
    
    DLog(@"^^^^^ you should not be in here! ^^^^^^^^");
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

- (void) returnFromOptions{
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate returnFromOptions];
}

@end



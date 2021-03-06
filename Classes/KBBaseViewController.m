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
#import "KBAccountManager.h"
#import "FacebookProxy.h"
#import "KBDialogueManager.h"
#import "GraphAPI.h"
#import "KBTwitterProfileViewController.h"
#import "Utilities.h"
#import "BusyAgent.h"


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
    DLog(@"kickball baseview viewdidload %i", [Utilities getMemory]);

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
            [foursquareTab setImage:[UIImage imageNamed:@"btn-footer4SQ03.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"btn-footerTW03.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"btn-footerFB01.png"] forState:UIControlStateNormal];
			if ([FacebookProxy instance].profilePic) {
				//DLog(@"[FacebookProxy instance].profilePic class: %@", [[FacebookProxy instance].profilePic class]);
				//DLog(@"[FacebookProxy instance].profilePic: %@", [FacebookProxy instance].profilePic);
				[signedInUserIcon setImage:[FacebookProxy instance].profilePic forState:UIControlStateNormal];
			} else {
				[signedInUserIcon setImage:[UIImage imageNamed:@"icon-default.png"] forState:UIControlStateNormal];
			}
			[signedInUserIcon setAdjustsImageWhenDisabled:NO];
			[signedInUserIcon setEnabled:NO];
            break;
        case KBFooterTypeTwitter:
            [foursquareTab setImage:[UIImage imageNamed:@"btn-footer4SQ03.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"btn-footerTW01.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"btn-footerFB03.png"] forState:UIControlStateNormal];
			NSString *twitUserPhotoURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitUserPhotoURL"];
			UIImage *twitterUserPic = [[Utilities sharedInstance] getCachedImage:twitUserPhotoURL];
			//if (twitterUserPic) [signedInUserIcon setImage:twitterUserPic forState:UIControlStateNormal];
			[signedInUserIcon setImage:twitterUserPic forState:UIControlStateNormal];
			// FIXME : this should be testing if user is logged in.  
			if (![[KBAccountManager sharedInstance] usesTwitter]) {
				[signedInUserIcon setAdjustsImageWhenDisabled:NO];
				[signedInUserIcon setEnabled:NO];
			}
            break;
        case KBFooterTypeFoursquare:
            [foursquareTab setImage:[UIImage imageNamed:@"btn-footer4SQ01.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"btn-footerTW03.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"btn-footerFB03.png"] forState:UIControlStateNormal];
			if (![[KBAccountManager sharedInstance] usesFoursquare]) {
				[signedInUserIcon setAdjustsImageWhenDisabled:NO];
				[signedInUserIcon setEnabled:NO];
			}
            break;
        default:
            [foursquareTab setImage:[UIImage imageNamed:@"btn-footer4SQ01.png"] forState:UIControlStateNormal];
            [twitterTab setImage:[UIImage imageNamed:@"btn-footerTW03.png"] forState:UIControlStateNormal];
            [facebookTab setImage:[UIImage imageNamed:@"btn-footerFB03.png"] forState:UIControlStateNormal];
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
	
	//Scott moved this one level up to the base clasee of each respective service
	/*
    [FlurryAPI logEvent:@"View User Profile from Top Nav Icon"];
    if ([self displaysTwitterUserProfile]) return;
	UserProfileViewController *pvc = [[UserProfileViewController alloc] initWithNibName:@"UserProfileView_v2" bundle:nil];
	pvc.userId = [self getAuthenticatedUser].userId;
	[self.navigationController pushViewController:pvc animated:YES];
	[pvc release];
	 */
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
	
    DLog(@"******************************************************");
    DLog(@"****** KBBaseViewController MEMORY WARNING!!! ********");
    DLog(@"******************************************************");
	
//	self.navigationController.viewControllers = [NSArray arrayWithObjects:[self.navigationController.viewControllers objectAtIndex:0], self, nil];
}

- (void)dealloc {
    [theTableView release];
    if (progressViewController) [progressViewController release];
    [loginViewModal release];
    if (popupView) [popupView release];
    
    if (refreshHeaderView) [refreshHeaderView release];
    
//    [iconImageView release];  // uncommenting this crashes shit. not sure why.
    //[progressBarTimer release];
    //[footerTabView release];
    
    [super dealloc];
	    DLog(@"kickball baseview dealloc %i", [Utilities getMemory]);

}

- (void)doLoginUsername: (NSString *)fsUser andPass:(NSString *) fsPass{
    
	[[FoursquareAPI sharedInstance] doLoginUsername:fsUser andPass:fsPass];
	[self dismissModalViewControllerAnimated:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenReceived:) name:MPOAuthNotificationAccessTokenReceived object:nil];
    
}

- (void)accessTokenReceived:(NSNotification *)inNotification {
	[self dismissModalViewControllerAnimated:YES];
}

- (void) startProgressBar:(NSString*)textToDisplay withTimer:(BOOL)shouldSetTimer andLongerTime:(BOOL)longerTime{
	
	DLog(@"################# starting progress bar #################");
	
	[[BusyAgent defaultAgent] queueBusy];
	
//	if (!progressViewController) {
//		progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressView" bundle:nil];
//	}
//	CGRect frame = progressViewController.view.frame;
//	frame.origin.y = frame.origin.y + 50;
//	progressViewController.view.frame = frame;
//	
//	[UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.4];
//	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//	progressViewController.view.frame = CGRectMake(0, 
//												   progressViewController.view.frame.origin.y - 50, 
//												   progressViewController.view.frame.size.width, 
//												   progressViewController.view.frame.size.height);
//    
//    [UIView commitAnimations];
//	
////    progressViewController.activityLabel.text = textToDisplay;
////    [progressViewController.activityLabel setShadowColor:[UIColor whiteColor]];
////    [progressViewController.activityLabel setShadowOffset:CGSizeMake(1, 1)];
//    [self.view addSubview:progressViewController.view];
    
    if (shouldSetTimer) {
        if (longerTime) {
            progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:PROGRESS_BAR_TIMER_LENGTH * 4 target:self selector:@selector(stopProgressBarAndDisplayErrorMessage:) userInfo:nil repeats:NO];        
        } else {
            progressBarTimer = [NSTimer scheduledTimerWithTimeInterval:PROGRESS_BAR_TIMER_LENGTH target:self selector:@selector(stopProgressBarAndDisplayErrorMessage:) userInfo:nil repeats:NO];        
        }
    }
}

- (void) startProgressBar:(NSString*)textToDisplay {
    [self startProgressBar:textToDisplay withTimer:YES andLongerTime:NO];
}

-(void) stopProgressBarAndDisplayErrorMessage:(NSTimer*)theTimer {
	[[BusyAgent defaultAgent] dequeueBusy];
//    [self stopProgressBar];
    
	// *** SCOTT ***  Scott thinks this error message is irrelevant and does not need to be called.
    /*
	KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"That's strange, the server didn't respond. Give it another try."];
    [self displayPopupMessage:message];
    [message release];
	 */
}

- (void) stopProgressBar {
	DLog(@"################# stopping progress bar #################");
	[[BusyAgent defaultAgent] dequeueBusy];
//    [progressBarTimer invalidate];
//    progressBarTimer = nil;
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//	
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//	[UIView setAnimationDuration:0.4];
//	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//	progressViewController.view.frame = CGRectMake(0, 
//												   progressViewController.view.frame.origin.y + 50, 
//												   progressViewController.view.frame.size.width, 
//												   progressViewController.view.frame.size.height);
//	
//	[UIView commitAnimations];
}

- (void) doInitialDisplay {
}

- (void) displayPopupMessage:(KBMessage*)message {
    [self stopProgressBar];
	[[KBDialogueManager sharedInstance] displayMessage:message];
}

// this is to be used when there is no possibility of having to add the message to an existing, displayed message
- (void) displayInfoPopupMessage:(KBMessage*)message {
    [self stopProgressBar];
	[[KBDialogueManager sharedInstance] displayInfoMessage:message];
}

- (void) displayPopupMessageWithFadeout:(KBMessage*)message {
	[[KBDialogueManager sharedInstance] displayMessageWithAutoFade:message];
}

- (void) displayPopupMessageForLogin:(KBMessage*)message {
    [self stopProgressBar];
	[self displayPopupMessage:message];
}

- (void) fadePopupMessage {
	[[KBDialogueManager sharedInstance] fadeOut];
}

- (void) viewSettings {
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate flipToOptions];
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
    //if ([self displaysTwitterUserProfile]) return;
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



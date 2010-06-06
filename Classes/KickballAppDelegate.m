//
//  KickballAppDelegate.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright Gorloch Interactive, LLC 2009. All rights reserved.
//

#import "KickballAppDelegate.h"
#import "FriendsListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "KBLocationManager.h"
#import "ASIHTTPRequest.h"
#import "FoursquareAPI.h"
#import "ProfileViewController.h"
#import "PopupMessageView.h"
#import "FlurryAPI.h"


@implementation KickballAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;
@synthesize twitterNavigationController;
@synthesize facebookNavigationController;
@synthesize user;
@synthesize deviceToken;
@synthesize deviceAlias;
@synthesize pushNotificationUserId;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    //[window addSubview:viewController.view];
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    application.applicationIconBadgeNumber = 0;
    
    [FlurryAPI startSession:@"00a9861658fbc22f2177620f22d9bb66"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [FlurryAPI logEvent:@"App launched!"];
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    if (manager.locationServicesEnabled == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
        [servicesDisabledAlert release];
    } else {
        [[UIApplication sharedApplication]
         registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                             UIRemoteNotificationTypeSound |
                                             UIRemoteNotificationTypeAlert)];
        [[KBLocationManager locationManager] startUpdates];
    }
    
    [manager release];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	hostReach = [[Reachability reachabilityWithHostName: @"apple.com"] retain];
	[hostReach startNotifer];
    
    [self checkForEmergencyMessage];
}

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}                                       
  
- (void)applicationWillTerminate:(UIApplication *)application {
    [[KBLocationManager locationManager] stopUpdates];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    DLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
	// Get a hex string from the device token with no spaces or < >
	self.deviceToken = [[[[_deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                         stringByReplacingOccurrencesOfString:@">" withString:@""] 
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    if ([[FoursquareAPI sharedInstance] isAuthenticated]) {
        
    }
}

- (void) setupAuthenticatedUserAndPushNotifications {
    [[FoursquareAPI sharedInstance] getUser:nil withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
}

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	FSUser* theUser = [FoursquareAPI userFromResponseXML:inString];
    [[FoursquareAPI sharedInstance] setCurrentUser:theUser];
    
	//Update View with the current token
//	[[viewController tokenDisplay] setText:  self.deviceToken];
    
	//NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
    //self.deviceAlias = [userDefaults stringForKey: @"_UADeviceAliasKey"];
    self.deviceAlias = theUser.userId;
    
	// Display the network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	// We like to use ASIHttpRequest classes, but you can make this register call how ever you like
	// just notice that it's an http PUT
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	NSString *UAServer = @"https://go.urbanairship.com";
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", self.deviceToken];
	NSURL *url = [NSURL URLWithString:  urlString];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.requestMethod = @"PUT";
	
	// Send along our device alias as the JSON encoded request body
	if(self.deviceAlias != nil && [self.deviceAlias length] > 0) {
		[request addRequestHeader: @"Content-Type" value: @"application/json"];
		[request appendPostData:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", self.deviceAlias]
                                 dataUsingEncoding:NSUTF8StringEncoding]];
	}
    
	// Authenticate to the server
	request.username = kApplicationKey;
	request.password = kApplicationSecret;
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(successMethod:)];
	[request setDidFailSelector: @selector(requestWentWrong:)];
	[queue addOperation:request];
	
	DLog(@"Device Token: %@", self.deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	DLog(@"Failed to register with error: %@", error);
}

- (void)successMethod:(ASIHTTPRequest *) request {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setValue: self.deviceToken forKey: @"_UALastDeviceToken"];
	[userDefaults setValue: self.deviceAlias forKey: @"_UALastAlias"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)requestWentWrong:(ASIHTTPRequest *)request {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSError *error = [request error];
	UIAlertView *someError = [[UIAlertView alloc] initWithTitle: 
							  @"Network error" message: @"Error registering with server"
                                                       delegate: self
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
	[someError show];
	[someError release];
	DLog(@"ERROR: NSError query result: %@", error);
}

// this is called when a user received a push notification but does NOT have the app open
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DLog(@"launch options: %@", launchOptions);
    [self applicationDidFinishLaunching:application];
    self.pushNotificationUserId = [[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey: @"aps"] objectForKey: @"uid"];
    if (launchOptions) {
        [self application:application didReceiveRemoteNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    return YES;
}

// this is called when a user received a push notification but DOES have the app open
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    self.pushNotificationUserId = [[userInfo objectForKey: @"aps"] objectForKey: @"uid"];

    // retrieve user info to get all the relavent data to display
    if([[FoursquareAPI sharedInstance] isAuthenticated]){
        [[FoursquareAPI sharedInstance] getUser:self.pushNotificationUserId withTarget:self andAction:@selector(pushUserResponseReceived:withResponseString:)];
    } else {
        DLog(@"this shouldn't happen ever!");
    }
}

- (void)pushUserResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"push notification response received");
	FSUser *pushedUser = [FoursquareAPI userFromResponseXML:inString];
    pushView = [[KBPushNotificationView alloc] initWithNibName:@"PushNotificationView" bundle:nil];
    pushView.view.frame = CGRectMake(0, 435, 320, 42);
    if (pushedUser.checkin.shout != nil) {
        pushView.messageLabel.text = [NSString stringWithFormat:@"%@ just shouted!", pushedUser.firstnameLastInitial];
        pushView.addressLabel.text = [NSString stringWithFormat:@"%@", pushedUser.checkin.shout];
    } else {
        pushView.messageLabel.text = [NSString stringWithFormat:@"%@ just checked in!", pushedUser.firstnameLastInitial];
        pushView.addressLabel.text = [NSString stringWithFormat:@"%@ / %@", pushedUser.checkin.venue.name, pushedUser.checkin.venue.addressWithCrossstreet];
    }
    [pushView.button addTarget:self action:@selector(viewUserProfile:) forControlEvents:UIControlEventTouchUpInside]; 
    pushView.view.alpha = 0;
    [navigationController.view addSubview:pushView.view];
    
    [UIView setAnimationsEnabled:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    pushView.view.alpha = 1.0;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (void) displayPushNotificationView:(NSNotification *)inNotification {
    ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView_v2" bundle:nil];
    profileController.userId = self.pushNotificationUserId;
    self.pushNotificationUserId = nil;
    [self.navigationController pushViewController:profileController animated:YES];
    [profileController release];
}


-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startFadeOut:) userInfo:nil repeats:NO];
}

-(void) startFadeOut:(NSTimer*)theTimer {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    pushView.view.alpha = 0.0;
    [UIView commitAnimations];
}

- (void) viewUserProfile:(id)sender {
    DLog(@"user pressed the view user profile push notification button");
    ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView_v2" bundle:nil];
    profileController.userId = self.pushNotificationUserId;
    self.pushNotificationUserId = nil;
    [self.navigationController pushViewController:profileController animated:YES];
    [profileController release];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	//[self updateInterfaceWithReachability: curReach];
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //BOOL connectionRequired= [curReach connectionRequired];
    //NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
//            statusString = @"Access Not Available";
//            imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
//            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
//            connectionRequired= NO;  
            
//            NSError *error = nil;
//            NSString *apiTestResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.apple.com"] encoding:NSASCIIStringEncoding error:&error];
//            DLog(@"api test error: %@", error);
//            DLog(@"api test response: %@", apiTestResponse);
//            if (error || [apiTestResponse rangeOfString:@"ok"].length == NSNotFound) {
//                UIAlertView *apiAlert = [[UIAlertView alloc] initWithTitle:@"Foursquare is Down" message:@"We're sorry. It looks like FourSquare servers are down temporarily. Please try again in a few minutes." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [apiAlert show];
//                [apiAlert release];
//            } else {
                KBMessage *message = [[KBMessage alloc] initWithMember:@"Network Error" andMessage:@"The network is down. Please try again shortly."];
                [self displayPopupMessage:message];
                [message release];
                
//            }
            break;
        }
            
//        case ReachableViaWWAN:
//        {
////            statusString = @"Reachable WWAN";
////            imageView.image = [UIImage imageNamed: @"WWAN5.png"];
//            break;
//        }
//        case ReachableViaWiFi:
//        {
////            statusString= @"Reachable WiFi";
////            imageView.image = [UIImage imageNamed: @"Airport.png"];
//            break;
//        }
    }
}

- (void) displayPopupMessage:(KBMessage*)message {
    
    popupView = [[PopupMessageView alloc] initWithNibName:@"PopupMessageView" bundle:nil];
    popupView.message = message;
    popupView.view.alpha = 0;
    [navigationController.view addSubview:popupView.view];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    popupView.view.alpha = 1.0;
    popupView.view.frame = CGRectMake(0, 0, popupView.view.frame.size.width, popupView.view.frame.size.height + 21);
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

- (void) checkForEmergencyMessage {
    NSError *error = nil;
	NSString *emergencyMessage = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.gorlochs.com/kickball/app/messages/kb.emergency.message"] 
                                                          encoding:NSASCIIStringEncoding
                                                             error:&error];
    if (emergencyMessage != nil && ![emergencyMessage isEqualToString:@""]) {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:emergencyMessage];
        [self displayPopupMessage:message];
        [message release];
	}
}

- (void) switchToTwitter {
    [window addSubview:twitterNavigationController.view];
}

- (void) switchToFoursquare {
    [window addSubview:navigationController.view];
}

- (void) switchToFacebook {
    [window addSubview:facebookNavigationController.view];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [popupView release];
    [super dealloc];
}


@end

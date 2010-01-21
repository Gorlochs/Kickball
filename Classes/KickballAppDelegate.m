//
//  KickballAppDelegate.m
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright Gorloch Interactive, LLC 2009. All rights reserved.
//

#import "KickballAppDelegate.h"
#import "FriendsListViewController.h"
#import "Beacon.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import "ASIHTTPRequest.h"
#import "FoursquareAPI.h"
#import "ProfileViewController.h"


@implementation KickballAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;
@synthesize user;
@synthesize deviceToken;
@synthesize deviceAlias;
@synthesize pushNotificationVenueId;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    application.applicationIconBadgeNumber = 0;
    
    // Pinch Analytics
    NSString *applicationCode = @"51512b37fa78552a6981778e1e652682";
    [Beacon initAndStartBeaconWithApplicationCode:applicationCode
                                  useCoreLocation:YES useOnlyWiFi:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	hostReach = [[Reachability reachabilityWithHostName: @"api.foursquare.com/v1/test"] retain];
	[hostReach startNotifer];
    
    // this is just a sample. this should be removed eventually.
    [[Beacon shared] startSubBeaconWithName:@"App launched!" timeSession:NO];
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
        [[LocationManager locationManager] startUpdates];
    }
    
    [manager release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [Beacon endBeacon];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
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
	
	NSLog(@"Device Token: %@", self.deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	NSLog(@"Failed to register with error: %@", error);
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
	NSLog(@"ERROR: NSError query result: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"remote notification: %@",[userInfo description]);
	NSLog(@"%@", [userInfo objectForKey: @"aps"]);
    //	NSString *message = [userInfo descriptionWithLocale:nil indent:1];
	//NSString* message =  [[[userInfo objectForKey: @"aps"] objectForKey: @"vid"] stringValue];
    self.pushNotificationVenueId = [[[userInfo objectForKey: @"aps"] objectForKey: @"vid"] stringValue];
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remote Notification" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
    
    // TODO: put up message box giving them a choice to go to the page
    if ([[FoursquareAPI sharedInstance] isAuthenticated]) {
        [self displayPushNotificationView:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPushNotificationView:) name:@"signInComplete" object:nil];
    }
}

- (void) displayPushNotificationView:(NSNotification *)inNotification {
    ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    profileController.userId = self.pushNotificationVenueId;
    self.pushNotificationVenueId = nil;
    [self.navigationController pushViewController:profileController animated:YES];
    [profileController release];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note {
    NSLog(@"################## reachability has changed ####################### - ", [note object]);
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
            // TODO: pop up the sorry message
            NSLog(@"*****************************************************************************");
            NSLog(@"******************* NO ACCESS TO FOURSQUARE API!!!! *************************");
            NSLog(@"*****************************************************************************");
//            statusString = @"Access Not Available";
//            imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
//            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
//            connectionRequired= NO;  
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


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

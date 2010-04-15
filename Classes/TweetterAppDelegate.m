// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "TweetterAppDelegate.h"
#import "TwitEditorController.h"
#import "HomeViewController.h"
#import "SelectImageSource.h"
#import "SettingsController.h"
#import "LocationManager.h"
#import "RepliesListController.h"
#import "DirectMessagesController.h"
#import "NavigationRotateController.h"
#import "TweetQueueController.h"
#import "AboutController.h"
#import "LoginController.h"
#import "MGTwitterEngine.h"
#import "FollowersController.h"
#import "MyTweetViewController.h"
#import "AccountController.h"
#import "TwTabController.h"
#import "ISVideoUploadEngine.h"
#import "AccountManager.h"
#import "util.h"

#import <MapKit/MapKit.h>

static int NetworkActivityIndicatorCounter = 0;

@interface TweetterAppDelegate(Private)
- (void)registerUserDefault;
@end

@implementation TweetterAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    [self registerUserDefault];

	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
	[NSURLCache setSharedURLCache:sharedCache];
	[sharedCache release];
	
    AccountManager *accountManager = [AccountManager manager];
    AccountController *accountController = [[AccountController alloc] initWithManager:accountManager];
    
    navigationController = [[NavigationRotateController alloc] initWithRootViewController:accountController];
    [accountController release];
    
    [window addSubview:navigationController.view];

	[[LocationManager locationManager] startUpdates];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)didRotate:(NSNotification*)notification
{
    @try
    {
        if ([navigationController.topViewController isKindOfClass:[TwTabController self]] &&
            ![navigationController.modalViewController isKindOfClass:[UIImagePickerController self]])
        {
            UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
                UIInterfaceOrientationIsLandscape(orientation))
            {
                TwitEditorController *editor = [[TwitEditorController alloc] initInCameraMode];
                [navigationController pushViewController:editor animated:YES];
                [editor release];
            }
        }
    }
    @catch (...)
    {
    }
}

#pragma mark Class methods implementation
+ (UINavigationController *)rootNavigationController
{
    return [(TweetterAppDelegate*)[UIApplication sharedApplication] navigationController];
}

+ (void)increaseNetworkActivityIndicator
{
	NetworkActivityIndicatorCounter++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NetworkActivityIndicatorCounter > 0;
}

+ (void)decreaseNetworkActivityIndicator
{
	NetworkActivityIndicatorCounter--;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NetworkActivityIndicatorCounter > 0;
}

+ (BOOL)isCurrentUserName:(NSString*)screenname
{
    UserAccount *account = [[AccountManager manager] loggedUserAccount];
    
    return (account) ? ([screenname isEqualToString:[account username]]) : NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"PhotoPlacePin"];
	if(!pinView)
    {
		pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PhotoPlacePin"] autorelease];
	}
	return pinView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if([views count] == 0)
		return;
    
	MKAnnotationView *pinView = [views objectAtIndex:0];
	MKCoordinateRegion region;
	MKCoordinateSpan span;
    
	span.latitudeDelta = 0.02;
	span.longitudeDelta = 0.02;
	region.span = span;
	region.center = pinView.annotation.coordinate;
	
	[mapView setRegion:region animated:NO];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	YFLog(@"mapViewWillStartLoadingMap");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	YFLog(@"mapViewDidFinishLoadingMap");
}

- (UIViewController *)googleMapLoadControllerWithRequest:(NSURLRequest *)request
{	
	if ([[[request URL] host] isEqualToString:@"maps.google.com"])
	{      
        NSDictionary *googleMapsCoords = GoogleMapsCoordsFromUrl([request URL]);
        if (googleMapsCoords)
		{
			NSString *latitude = [googleMapsCoords objectForKey:@"latitude"];
			NSString *longtitude = [googleMapsCoords objectForKey:@"longtitude"];
			
			Class MapViewClass = NSClassFromString(@"MKMapView");
			if (nil != MapViewClass)
			{
				CGRect mapViewFrame = self.window.frame;
				id mapView = [[MapViewClass alloc] initWithFrame:mapViewFrame];
				[mapView setDelegate:self];
				
				UIViewController *container = [[UIViewController alloc] init];
				container.title = @"Maps";
				container.view = mapView;
				[mapView release];
				
				CLLocationCoordinate2D location;
				
				YFLog(@"Map: %@, %@", latitude, longtitude);
				
				location.latitude = [latitude doubleValue];
				location.longitude = [longtitude doubleValue];
				
				MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:[NSDictionary dictionary]];
				[mapView addAnnotation:place];
				[place release];
				
				return [container autorelease];
			}
		}
	}
	
	return nil;
}

- (BOOL)startOpenGoogleMapsRequest:(NSURLRequest *)request
{
	BOOL success = NO;

	Class MapViewClass = NSClassFromString(@"MKMapView");
	if (MapViewClass == nil)
	{
        [[UIApplication sharedApplication] openURL:[request URL]];
	}
	else
	{
		UIViewController *mapLoadController = [self googleMapLoadControllerWithRequest:request];
		if (nil != mapLoadController)
		{
			[self.navigationController pushViewController:mapLoadController animated:NO];
			success = YES;
		}
	}
	
	return success;
}

@end

@implementation TweetterAppDelegate(Private)
// Register user defaults
- (void)registerUserDefault
{
	NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	[appDefaults release];
}

@end

//
//  KBGeoTweetMapViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/27/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBGeoTweetMapViewController.h"
#import "KBLocationManager.h"
#import "KBSearchResult.h"
#import "VenueAnnotation.h"
#import "KBPin.h"

#define GEO_TWITTER_RADIUS 5


@implementation KBGeoTweetMapViewController

@synthesize mapViewer;

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeMap;
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRetrieved:) name:kTwitterSearchRetrievedNotificationKey object:nil];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    [self startProgressBar:@"Retrieving your tweets..."];
    [self executeQuery:0];
}

- (void)searchRetrieved:(NSNotification *)inNotification {
    if (inNotification && [inNotification userInfo]) {
        NSDictionary *userInfo = [inNotification userInfo];
        if ([userInfo objectForKey:@"searchResults"]) {
            statuses = [[[[userInfo objectForKey:@"searchResults"] objectAtIndex:0] objectForKey:@"results"] retain];
            if (!nearbyTweets) {
                nearbyTweets = [[NSMutableArray alloc] initWithCapacity:1];
            }
            for (NSDictionary *dict in statuses) {
                KBSearchResult *result = [[KBSearchResult alloc] initWithDictionary:dict];
                if (result.latitude > 0.0) {
                    [nearbyTweets addObject:result];
                }
                [result release];
            }
            [self refreshMap];
            NSLog(@"number of nearby tweets: %d", [nearbyTweets count]);
            if (pageNum < 3) {
                [self executeQuery:++pageNum];
            }
        }
    }
    [self stopProgressBar];
}

- (void) executeQuery:(int)pageNumber {
    [twitterEngine getSearchResultsForQuery:nil
                                    sinceID:0 
                             startingAtPage:pageNumber
                                      count:100
                                    geocode:[NSString stringWithFormat:@"%@,%@,%dmi", 
                                             [NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]],
                                             [NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]],
                                             GEO_TWITTER_RADIUS
                                             ]
     ];
}

#pragma mark -
#pragma mark Map stuff


//- (void) zoomToProperDepth {
//    if (nearbyTweets && nearbyTweets.count > 0)
//	{
//        //		NSLog(@"checkins count: %d", checkins.count);
//		
//        double minLat = 1000;
//        double maxLat = -1000;
//        double minLong = 1000;
//        double maxLong = -1000;
//        
//        for (KBSearchResult *tweets in nearbyTweets)
//        {
//        	double lat = venue.geolat.doubleValue;
//        	double lng = venue.geolong.doubleValue;
//        	
//        	if (lat < minLat)
//        	{
//        		minLat = lat;
//        	}
//        	if (lat > maxLat)
//        	{
//        		maxLat = lat;
//        	}
//        	
//        	if (lng < minLong)
//        	{
//        		minLong = lng;
//        	}
//        	if (lng > maxLong)
//        	{
//        		maxLong = lng;
//        	}
//        }
//		
//		//MKCoordinateRegion region;
//		MKCoordinateSpan span;
//        span.latitudeDelta=(maxLat - minLat);
//        if (span.latitudeDelta == 0)
//        {
//            span.latitudeDelta = 0.05;
//        }
//        span.longitudeDelta=(maxLong - minLong);
//        if (span.longitudeDelta == 0)
//        {
//            span.longitudeDelta = 0.05;
//        }
//		
//		CLLocationCoordinate2D center;
//        center.latitude = (minLat + maxLat) / 2;
//        center.longitude = (minLong + maxLong) / 2;
//    }
//}

- (void) refreshMapRegion {
	[mapViewer setRegion:mapRegion animated:TRUE];
	[mapViewer regionThatFits:mapRegion];
}

- (void) refreshMap {
    
//    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:1];
//    for (id<MKAnnotation> annotation in mapViewer.annotations) {
//        if( ![[annotation title] isEqualToString:@"Current Location"] ) {
//            [tmpArray addObject:annotation];
//        }
//    }
//    [mapViewer removeAnnotations:tmpArray];
//    [tmpArray release];
    
    double minLat = 1000;
    double maxLat = -1000;
    double minLong = 1000;
    double maxLong = -1000;
    
    for (KBSearchResult *tweet in nearbyTweets)
    {
        double lat = tweet.latitude;
        double lng = tweet.longitude;
        
        if (lat < minLat)
        {
            minLat = lat;
        }
        if (lat > maxLat)
        {
            maxLat = lat;
        }
        
        if (lng < minLong)
        {
            minLong = lng;
        }
        if (lng > maxLong)
        {
            maxLong = lng;
        }
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=(maxLat - minLat);
    if (span.latitudeDelta == 0)
    {
        span.latitudeDelta = 0.05;
    }
    span.longitudeDelta=(maxLong - minLong);
    if (span.longitudeDelta == 0)
    {
        span.longitudeDelta = 0.05;
    }
    
    CLLocationCoordinate2D center;
    center.latitude = (minLat + maxLat) / 2;
    center.longitude = (minLong + maxLong) / 2;
    
    region.span = span;
    region.center = center;
    
	for(KBSearchResult *tweet in nearbyTweets){
		if(tweet.latitude && tweet.longitude){
            
            CLLocationCoordinate2D location = {
                latitude: tweet.latitude,
                longitude: tweet.longitude
            };
            [mapViewer setRegion:region animated:NO];
            [mapViewer regionThatFits:region];
            
            VenueAnnotation *anote = [[VenueAnnotation alloc] init];
            anote.coordinate = location;
            anote.title = tweet.screenName;
            anote.subtitle = tweet.tweetText;
            NSLog(@"annotation title: %@", anote.title);
            [mapViewer addAnnotation:anote];
            [anote release];
		}
	}
    
    // does this go here?
    [self stopProgressBar];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if( [[annotation title] isEqualToString:@"Current Location"] ) {
		return nil;
	}
//    int postag = 0;
    
    KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
    annView.image = [UIImage imageNamed:@"pin.png"];
    
    // add an accessory button so user can click through to the venue page
    UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myDetailButton.frame = CGRectMake(0, 0, 23, 23);
    myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    // Set the image for the button
    [myDetailButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
    //[myDetailButton addTarget:self action:@selector(showVenue:) forControlEvents:UIControlEventTouchUpInside]; 
    
    //postag = [((VenueAnnotation*)annotation).venueId intValue];
    //myDetailButton.tag = postag;
    
    // Set the button as the callout view
    annView.rightCalloutAccessoryView = myDetailButton;
    
    //annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    //annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}

#pragma mark -
#pragma mark memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [mapViewer removeAnnotations:mapViewer.annotations];
    mapViewer.delegate = nil;
    mapViewer.showsUserLocation = NO;
    mapViewer = nil;
    [mapViewer performSelector:@selector(release) withObject:nil afterDelay:4.0f];
    
    [nearbyTweets release];
    [super dealloc];
}


@end

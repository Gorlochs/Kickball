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


#define GEO_TWITTER_RADIUS 10


@implementation KBGeoTweetMapViewController

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeMap;
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRetrieved:) name:kTwitterSearchRetrievedNotificationKey object:nil];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets01.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
    
    
}

- (void) showStatuses {
    [self startProgressBar:@"Retrieving your tweets..."];
    [self executeQuery:0];
}

- (void)searchRetrieved:(NSNotification *)inNotification {
    NSLog(@"inside searchRetrieved: %@", inNotification);
    if (inNotification && [inNotification userInfo]) {
        NSDictionary *userInfo = [inNotification userInfo];
        if ([userInfo objectForKey:@"searchResults"]) {
            statuses = [[userInfo objectForKey:@"searchResults"] retain];
            tweets = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
            //int i = 0;
            for (NSDictionary *dict in statuses) {
                [tweets addObject:[[KBSearchResult alloc] initWithDictionary:dict]];
            }
            //[self refreshMap];
        }
    }
    [self stopProgressBar];
}

- (void) executeQuery:(int)pageNumber {
    [twitterEngine getSearchResultsForQuery:nil
                                    sinceID:0 
                             startingAtPage:pageNumber
                                      count:25 
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
//    if (self.venues && self.venues.count > 0)
//	{
//        //		NSLog(@"checkins count: %d", checkins.count);
//		
//        double minLat = 1000;
//        double maxLat = -1000;
//        double minLong = 1000;
//        double maxLong = -1000;
//        
//        for (FSVenue *venue in self.venues)
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
//
//- (void) refreshVenuePoints {
//    
//    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:1];
//    for (id<MKAnnotation> annotation in mapViewer.annotations) {
//        if( ![[annotation title] isEqualToString:@"Current Location"] ) {
//            [tmpArray addObject:annotation];
//        }
//    }
//    [mapViewer removeAnnotations:tmpArray];
//    [tmpArray release];
//    
//    double minLat = 1000;
//    double maxLat = -1000;
//    double minLong = 1000;
//    double maxLong = -1000;
//    
//    for (FSVenue *venue in self.venues)
//    {
//        double lat = venue.geolat.doubleValue;
//        double lng = venue.geolong.doubleValue;
//        
//        if (lat < minLat)
//        {
//            minLat = lat;
//        }
//        if (lat > maxLat)
//        {
//            maxLat = lat;
//        }
//        
//        if (lng < minLong)
//        {
//            minLong = lng;
//        }
//        if (lng > maxLong)
//        {
//            maxLong = lng;
//        }
//    }
//    
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta=(maxLat - minLat);
//    if (span.latitudeDelta == 0)
//    {
//        span.latitudeDelta = 0.05;
//    }
//    span.longitudeDelta=(maxLong - minLong);
//    if (span.longitudeDelta == 0)
//    {
//        span.longitudeDelta = 0.05;
//    }
//    
//    CLLocationCoordinate2D center;
//    center.latitude = (minLat + maxLat) / 2;
//    center.longitude = (minLong + maxLong) / 2;
//    
//    region.span = span;
//    region.center = center;
//    
//	for(KBTweet *tweet in tweets){
//		//FSVenue * checkVenue = checkin.venue; 
//		if(tweet.geolat && venue.geolong){
//            
//            CLLocationCoordinate2D location = venue.location;
//            [mapViewer setRegion:region animated:NO];
//            [mapViewer regionThatFits:region];
//            
//            VenueAnnotation *anote = [[VenueAnnotation alloc] init];
//            anote.coordinate = location;
//            anote.title = venue.name;
//            anote.venueId = venue.venueid;
//            anote.subtitle = venue.addressWithCrossstreet;
//            [mapViewer addAnnotation:anote];
//            [anote release];
//            
//            //            MKAnnotationView *av = [[MKAnnotationView alloc] initWithAnnotation:anote reuseIdentifier:@"testing"];
//            //            av.rightCalloutAccessoryView
//		}
//	}
//    
//    // does this go here?
//    [self stopProgressBar];
//}


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
    [super dealloc];
}


@end

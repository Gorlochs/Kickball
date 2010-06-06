//
//  KBGeoTweetMapViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/27/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBGeoTweetMapViewController.h"
#import "KBLocationManager.h"
#import "IFTweetLabel.h"

#define GEO_TWITTER_RADIUS 5


@implementation KBGeoTweetMapViewController

@synthesize mapViewer;
@synthesize popupBubbleView;
@synthesize touchView;

NSString * const GMAP_ANNOTATION_SELECTED = @"gmapselected";

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeMap;
    [super viewDidLoad];
    
    pageNum = 0;
    mapCenterCoordinate.latitude = [[KBLocationManager locationManager] latitude];
    mapCenterCoordinate.longitude = [[KBLocationManager locationManager] longitude];
    
    touchView = [[TouchView alloc] initWithFrame:CGRectMake(0, 47, 320, 373)];
	touchView.delegate = self;
	touchView.callAtHitTest = @selector(stopFollowLocation);
	
    mapViewer = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 373)];
	mapViewer.delegate = self;
    [touchView addSubview:mapViewer];
    
    [self.view addSubview:touchView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRetrieved:) name:kTwitterSearchRetrievedNotificationKey object:nil];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
    
    // this should TOTALLY be inside the KBMapPopupView, but I couldn't find an init method that is actually being called.
    self.popupBubbleView.frame = CGRectMake(20.0, 250.0 + 300 , self.popupBubbleView.frame.size.width, self.popupBubbleView.frame.size.height);
    self.popupBubbleView.tweetText = [[IFTweetLabel alloc] initWithFrame:CGRectMake(8, 29, 250, 50)];
    self.popupBubbleView.tweetText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    self.popupBubbleView.tweetText.font = [UIFont fontWithName:@"Georgia" size:12.0];
    self.popupBubbleView.tweetText.backgroundColor = [UIColor clearColor];
    self.popupBubbleView.tweetText.linksEnabled = YES;
    self.popupBubbleView.tweetText.numberOfLines = 0;
    [self.popupBubbleView addSubview:self.popupBubbleView.tweetText];
    
    [self.touchView addSubview:self.popupBubbleView];
}

- (void) showStatuses {
    [self startProgressBar:@"Retrieving your tweets..."];
    [self executeQueryWithPageNumber:pageNum andCoordinates:mapCenterCoordinate];
}

- (void)searchResultsReceived:(NSArray *)searchResults {
	if (searchResults) {
		NSLog(@"search results: %@", searchResults);

		twitterArray = [[[searchResults objectAtIndex:0] objectForKey:@"results"] retain];
		if (!nearbyTweets) {
			nearbyTweets = [[NSMutableArray alloc] initWithCapacity:1];
		}
		for (NSDictionary *dict in twitterArray) {
			KBSearchResult *result = [[KBSearchResult alloc] initWithDictionary:dict];
			if (result.latitude > 0.0) {
				[nearbyTweets addObject:result];
			}
			[result release];
		}
		[self refreshMap];
		NSLog(@"number of nearby tweets: %d", [nearbyTweets count]);
		if (pageNum < 4 && [nearbyTweets count] < 25 + 25 * numTouches) {
			[self executeQueryWithPageNumber:++pageNum andCoordinates:mapViewer.centerCoordinate];
		}
	}
    [self stopProgressBar];
}

- (void) executeQuery:(int)pageNumber {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[KBLocationManager locationManager] latitude];
    coordinate.longitude = [[KBLocationManager locationManager] longitude];
    [self executeQueryWithPageNumber:pageNumber andCoordinates:coordinate];
}

- (void)executeQueryWithPageNumber:(int)pageNumber andCoordinates:(CLLocationCoordinate2D)coordinate {
    [twitterEngine getSearchResultsForQuery:nil
                                    sinceID:0 
                             startingAtPage:pageNumber
                                      count:100
                                    geocode:[NSString stringWithFormat:@"%@,%@,%dmi", 
                                             [NSString stringWithFormat:@"%f",coordinate.latitude],
                                             [NSString stringWithFormat:@"%f",coordinate.longitude],
                                             GEO_TWITTER_RADIUS
                                             ]
     ];
}

#pragma mark -
#pragma mark Map stuff

- (void) calculateMapCenterAndRegion {
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
    
    [mapViewer setRegion:region animated:NO];
    [mapViewer regionThatFits:region];
}

- (void) refreshMap {
    
    if (numTouches == 0) {
        [self calculateMapCenterAndRegion];
    }
    
	for(KBSearchResult *tweet in nearbyTweets){
		if(tweet.latitude && tweet.longitude){
            
            CLLocationCoordinate2D location = {
                latitude: tweet.latitude,
                longitude: tweet.longitude
            };
            
            GeoTweetAnnotation *anote = [[GeoTweetAnnotation alloc] init];
            anote.coordinate = location;
            anote.title = tweet.screenName;
            anote.subtitle = tweet.tweetText;
            anote.searchResult = tweet;
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
    
    KBPin *annView=[[[KBPin alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomId"] autorelease];
    annView.image = [UIImage imageNamed:@"pin.png"];
    
    [annView addObserver:self
              forKeyPath:@"selected"
                 options:NSKeyValueObservingOptionNew
                 context:GMAP_ANNOTATION_SELECTED];
    annView.canShowCallout = NO;
    return annView;
}

- (void) annotationClicked: (id <MKAnnotation>) annotation {
	KBPin* ann = (KBPin*) annotation;
	NSLog(@"Annotation clicked: %@", ann.title);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CustomCalloutMapView" message:[NSString stringWithFormat:@"You clicked at annotation: %@",ann.title] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
    NSString *action = (NSString*)context;
	
    if([action isEqualToString:GMAP_ANNOTATION_SELECTED]){
		BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
		if (annotationAppeared) {
			NSLog(@"annotation selected %@", ((KBPin*) object).annotation.title);
			[self showAnnotation:((KBPin*) object).annotation];
			((KBPin*) object).image = [UIImage imageNamed:@"pin.png"];
		} else {
			NSLog(@"annotation deselected %@", ((KBPin*) object).annotation.title);
			[self hideAnnotation];
			((KBPin*) object).image = [UIImage imageNamed:@"pin.png"];
		}
	}
}

- (void) stopFollowLocation {
	NSLog(@"stopFollowLocation called. Good place to put stop follow location annotation code.");
	
	GeoTweetAnnotation* annotation;
	for (annotation in mapViewer.selectedAnnotations) {
		[mapViewer deselectAnnotation:annotation animated:NO];
	}
	
	[self hideAnnotation];
	
}

- (void)showAnnotation:(GeoTweetAnnotation*)annotation {
	self.popupBubbleView.screenname.text = annotation.title;
    self.popupBubbleView.tweetText.text = annotation.subtitle;
    currentlyDisplayedSearchResult = annotation.searchResult;
	[UIView beginAnimations: @"moveCNGCallout" context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDuration: 0.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	self.popupBubbleView.frame = CGRectMake(10.0, 250.0, self.popupBubbleView.frame.size.width, self.popupBubbleView.frame.size.height);
	[UIView commitAnimations];
}

- (void)hideAnnotation {
	[UIView beginAnimations: @"moveCNGCalloutOff" context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDuration: 0.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
	self.popupBubbleView.frame = CGRectMake(10.0, 250.0 + 300, self.popupBubbleView.frame.size.width, self.popupBubbleView.frame.size.height);
    [UIView commitAnimations];
	self.popupBubbleView.screenname.text = nil;
	self.popupBubbleView.tweetText.text = nil;
    currentlyDisplayedSearchResult = nil;
}

#pragma mark MKMapViewDelegate functions

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (isMapFinishedLoading) {
        numTouches++;
        isMapFinishedLoading = NO;
        CLLocationCoordinate2D newCenterCoordinate = mapView.centerCoordinate;
        [self executeQueryWithPageNumber:pageNum andCoordinates:newCenterCoordinate];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    isMapFinishedLoading = YES;
}

#pragma mark -
#pragma mark IBOutlets

- (void) replyToTweet {
    NSLog(@"reply to tweet id: %qu", [currentlyDisplayedSearchResult.tweetId longLongValue]);
	replyCreateViewController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    replyCreateViewController.replyToStatusId = currentlyDisplayedSearchResult.tweetId;
    replyCreateViewController.replyToScreenName = currentlyDisplayedSearchResult.screenName;
	[self presentModalViewController:replyCreateViewController animated:YES];
}

- (void) retweet {
    NSLog(@"**********retweet**************");
	retweetCreateViewController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    retweetCreateViewController.replyToStatusId = currentlyDisplayedSearchResult.tweetId;
    retweetCreateViewController.replyToScreenName = currentlyDisplayedSearchResult.screenName;
    retweetCreateViewController.retweetTweetText = currentlyDisplayedSearchResult.tweetText;
	[self presentModalViewController:retweetCreateViewController animated:YES];
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
    popupBubbleView = nil;
    currentlyDisplayedSearchResult = nil;
}


- (void)dealloc {
    [mapViewer removeAnnotations:mapViewer.annotations];
    mapViewer.delegate = nil;
    mapViewer.showsUserLocation = NO;
    mapViewer = nil;
    [mapViewer performSelector:@selector(release) withObject:nil afterDelay:4.0f];
    
    [nearbyTweets release];
    [currentlyDisplayedSearchResult release];
    [touchView release];
    [popupBubbleView release];
    
	[replyCreateViewController release];
	[retweetCreateViewController release];
    [super dealloc];
}


@end

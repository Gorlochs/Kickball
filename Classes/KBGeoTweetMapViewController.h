//
//  KBGeoTweetMapViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/27/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KBBaseTweetViewController.h"
#import "KBMapPopupView.h"
#import "KBPin.h"
#import "GeoTweetAnnotation.h"
#import "TouchView.h"
#import "KBSearchResult.h"
#import "KBCreateTweetViewController.h"


@interface KBGeoTweetMapViewController : KBBaseTweetViewController <MKMapViewDelegate> {
	IBOutlet MKMapView * mapViewer;
	MKCoordinateRegion mapRegion;
    CLLocationCoordinate2D mapCenterCoordinate;
    NSMutableArray *nearbyTweets;
    IBOutlet KBMapPopupView *popupBubbleView;
	TouchView* touchView;
    KBSearchResult *currentlyDisplayedSearchResult;
    BOOL isMapFinishedLoading;
    
    KBCreateTweetViewController *replyCreateViewController;
    KBCreateTweetViewController *retweetCreateViewController;
    
    int numTouches;
}

@property (nonatomic, retain) MKMapView *mapViewer;
@property (nonatomic, retain) KBMapPopupView *popupBubbleView;
@property (nonatomic, retain) TouchView* touchView;
extern NSString *const GMAP_ANNOTATION_SELECTED;

- (void) refreshMap;
- (void)showAnnotation:(GeoTweetAnnotation*)annotation;
- (void)hideAnnotation;
- (IBAction) replyToTweet;
- (IBAction) retweet;
- (void)executeQueryWithPageNumber:(int)pageNumber andCoordinates:(CLLocationCoordinate2D)coordinate;

@end

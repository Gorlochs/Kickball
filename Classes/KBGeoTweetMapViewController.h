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
#import "VenueAnnotation.h"
#import "TouchView.h"


@interface KBGeoTweetMapViewController : KBBaseTweetViewController <MKMapViewDelegate> {
	IBOutlet MKMapView * mapViewer;
	MKCoordinateRegion mapRegion;
    NSMutableArray *nearbyTweets;
    IBOutlet KBMapPopupView *popupBubbleView;
	TouchView* touchView;
}

@property (nonatomic, retain) MKMapView *mapViewer;
@property (nonatomic, retain) KBMapPopupView *popupBubbleView;
@property (nonatomic, retain) TouchView* touchView;
extern NSString *const GMAP_ANNOTATION_SELECTED;

- (void) refreshMap;
- (void)showAnnotation:(VenueAnnotation*)annotation;
- (void)hideAnnotation;

@end

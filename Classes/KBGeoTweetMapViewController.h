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


@interface KBGeoTweetMapViewController : KBBaseTweetViewController <MKMapViewDelegate> {
	IBOutlet MKMapView * mapViewer;
	MKCoordinateRegion mapRegion;
    NSMutableArray *nearbyTweets;
}

- (void) refreshMap;

@end

//
//  PlaceMapViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FSVenue.h"
#import "KBBaseViewController.h"


@interface PlaceMapViewController : KBBaseViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *theMapView;
    FSVenue *venue;
}

@property (nonatomic, retain) FSVenue *venue;

- (void) showVenue:(id)sender;

@end

//
//  VenueAnnotation.h
//  Kickball
//
//  Created by Shawn Bernard on 11/9/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VenueAnnotation : NSObject<MKAnnotation> {
    NSString *title;
    NSString *subtitle;
	CLLocationCoordinate2D coordinate;
    NSString *venueId;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *venueId;

@end

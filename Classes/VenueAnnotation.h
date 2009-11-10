//
//  VenueAnnotation.h
//  Kickball
//
//  Created by Shawn Bernard on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface VenueAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}


@end

//
//  GeoTweetAnnotation.h
//  Kickball
//
//  Created by Shawn Bernard on 5/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "KBSearchResult.h"


@interface GeoTweetAnnotation : NSObject<MKAnnotation> {
    NSString *title;
    NSString *subtitle;
	NSString *iconUrl;
	CLLocationCoordinate2D coordinate;
    KBSearchResult *searchResult;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *iconUrl;
@property (nonatomic, retain) KBSearchResult *searchResult;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c;

@end

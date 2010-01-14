//
//  FriendPlacemark.m
//  Kickball
//
//  Created by David Evans on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FriendPlacemark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString * url;
    NSString *userId;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end

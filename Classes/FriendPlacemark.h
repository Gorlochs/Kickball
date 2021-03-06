//
//  FriendPlacemark.m
//  Kickball
//
//  Created by David Evans on 11/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FSCheckin.h"

@interface FriendPlacemark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    FSCheckin *checkin;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) FSCheckin *checkin;

- (id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end

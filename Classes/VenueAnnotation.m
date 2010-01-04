//
//  VenueAnnotation.m
//  Kickball
//
//  Created by Shawn Bernard on 11/9/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "VenueAnnotation.h"


@implementation VenueAnnotation

@synthesize coordinate, title, subtitle;

//- (NSString *)subtitle{
//	return nil;
//}

//- (NSString *)title{
//	return nil;
//}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate = c;
	return self;
}


@end

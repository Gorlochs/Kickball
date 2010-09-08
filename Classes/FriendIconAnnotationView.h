//
//  FriendIconAnnotationView.h
//  Kickball
//
//  Created by David Evans on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<MapKit/MapKit.h>
#import "FSCheckin.h"
#import "Three20/Three20.h"


@interface FriendIconAnnotationView : MKAnnotationView {
	CLLocationCoordinate2D _coordinate;
	//UIImageView * imageView;
	TTImageView *imageView;
	NSString* title;
	NSString* subtitle;
	NSString* userData;
	NSString* userId;
	NSURL* url;
}

- (id)initWithAnnotation:(id )annotation reuseIdentifier:(NSString *)reuseIdentifier andCheckin:(FSCheckin *) url;

@property (nonatomic, retain) TTImageView * imageView;
@property (nonatomic, retain) NSString* userData;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* subtitle;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSURL* url;


@end

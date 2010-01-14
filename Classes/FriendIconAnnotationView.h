//
//  FriendIconAnnotationView.h
//  Kickball
//
//  Created by David Evans on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<MapKit/MapKit.h>


@interface FriendIconAnnotationView : MKAnnotationView {
	CLLocationCoordinate2D _coordinate;
	UIImageView * imageView;
	NSString* title;
	NSString* subtitle;
	NSString* userData;
	NSString* userId;
	NSURL* url;
}

- (id)initWithAnnotation:(id )annotation reuseIdentifier:(NSString *)reuseIdentifier andImageUrl:(NSString *) url;

@property (nonatomic, retain) UIImageView * imageView;
@property (nonatomic, retain) NSString* userData;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* subtitle;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSURL* url;


@end

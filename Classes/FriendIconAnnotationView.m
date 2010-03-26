//
//  FriendIconAnnotationView.m
//  Kickball
//
//  Created by David Evans on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FriendIconAnnotationView.h"
#import "Utilities.h"
#import "ProfileViewController.h"
#import "FriendsMapViewController.h"

#define kHeight 32
#define kWidth 32
#define kBorder 2

@implementation FriendIconAnnotationView
@synthesize imageView, userData, title, subtitle, url, userId;

- (id)initWithAnnotation:(id )annotation reuseIdentifier:(NSString *)reuseIdentifier andCheckin:(FSCheckin *) checkin{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	self.frame = CGRectMake(0, 0, kWidth, kHeight);
	self.backgroundColor = [UIColor whiteColor];
	if (checkin.user.photo){
        //NSLog(@"map icon url: %@", inUrl);
        imageView = [[UIImageView alloc] initWithImage:[[Utilities sharedInstance] getCachedImage:checkin.user.photo]];
		imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
        imageView.alpha = 1.0;
        self.alpha = 1.0;
        imageView.backgroundColor = [UIColor clearColor];
		[self addSubview:imageView];
	}
		
	return self;
}

-(void) dealloc {
    [title release];
    [subtitle release];
    [url release];
    [userId release];
    [userData release];
	[imageView release];
	[super dealloc];
}

@end
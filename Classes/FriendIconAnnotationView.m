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
        
        NSDate *checkinDate = [[[Utilities sharedInstance] foursquareCheckinDateFormatter] dateFromString:checkin.created];
        NSDate *localCheckinDate = [Utilities convertUTCCheckinDateToLocal:checkinDate];
        NSTimeInterval interval = [localCheckinDate timeIntervalSinceNow];
        NSLog(@"******* interval in hours %d", (int)(interval/(-60*60)));
        int intervalHours = (int)(interval/(-60*60));
        float fadedAlpha = 0.25;
        if (interval < 24) {
            fadedAlpha = (24.0 - intervalHours*0.75) / 24.0;
            NSLog(@"*** alpha: %f", fadedAlpha);
        }
        
        imageView.alpha = fadedAlpha;
        self.alpha = fadedAlpha;
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
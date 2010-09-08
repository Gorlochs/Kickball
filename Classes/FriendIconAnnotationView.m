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
        //DLog(@"map icon url: %@", inUrl);
		CGRect frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
        imageView = [[TTImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.defaultImage = [UIImage imageNamed:@"blank.png"];
		imageView.urlPath = checkin.user.photo;
        imageView.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:3 topRight:3 bottomRight:3 bottomLeft:3] next:[TTContentStyle styleWithNext:nil]];
        
//        imageView = [[TTImageView alloc] initWithImage:[[Utilities sharedInstance] getCachedImage:checkin.user.photo]];
//		imageView.frame = CGRectMake(kBorder, kBorder, kWidth - 2 * kBorder, kWidth - 2 * kBorder);
        
//        NSDate *checkinDate = [[[Utilities sharedInstance] foursquareCheckinDateFormatter] dateFromString:checkin.created];
//        NSDate *localCheckinDate = [Utilities convertUTCCheckinDateToLocal:checkinDate];
//        NSTimeInterval interval = [localCheckinDate timeIntervalSinceNow];
//        DLog(@"******* interval in hours %d", (int)(interval/(-60*60)));
//        int intervalHours = (int)(interval/(-60*60));
//        float fadedAlpha = 0.25;
//        if (interval < 24) {
//            fadedAlpha = (24.0 - intervalHours*0.75) / 24.0;
//            DLog(@"*** alpha: %f", fadedAlpha);
//        }
//        
//        imageView.alpha = fadedAlpha;
//        self.alpha = fadedAlpha;
		
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
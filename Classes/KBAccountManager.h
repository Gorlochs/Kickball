//
//  KBAccountManager.h
//  Kickball
//
//  Created by Shawn Bernard on 5/21/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KBAccountManager : NSObject {
    BOOL usesTwitter;
    BOOL usesFacebook;
	BOOL usesFoursquare;
	BOOL shouldPostPhotosToFacebook;
	BOOL defaultPostToFacebook;
	BOOL defaultPostToTwitter;
	BOOL defaultPostToFoursquare;
	BOOL usesGeoTag;
	BOOL firstRunCompleted;
}

@property (nonatomic) BOOL usesTwitter;
@property (nonatomic) BOOL usesFacebook;
@property (nonatomic) BOOL usesFoursquare;
@property (nonatomic) BOOL usesGeoTag;
@property (nonatomic) BOOL shouldPostPhotosToFacebook;
@property (nonatomic) BOOL defaultPostToFacebook;
@property (nonatomic) BOOL defaultPostToTwitter;
@property (nonatomic) BOOL defaultPostToFoursquare;

+ (KBAccountManager*)sharedInstance;
- (BOOL) usesFacebookOrHasNotDecided;
- (BOOL) usesTwitterOrHasNotDecided;

- (BOOL) twitterPollinatesFoursquare;
- (BOOL) twitterPollinatesFacebook;
- (BOOL) facebookPollinatesFoursquare;
- (BOOL) facebookPollinatesTwitter;
- (BOOL) foursquarePollinatesTwitter;
- (BOOL) foursquarePollinatesFacebook;
- (void) setTwitterPollinatesFoursquare:(BOOL)should;
- (void) setTwitterPollinatesFacebook:(BOOL)should;
- (void) setFacebookPollinatesFoursquare:(BOOL)should;
- (void) setFacebookPollinatesTwitter:(BOOL)should;
- (void) setFoursquarePollinatesTwitter:(BOOL)should;
- (void) setFoursquarePollinatesFacebook:(BOOL)should;
-(void)checkForCrossPollinateWarning:(NSString*)service;
-(void)displayCrossPollinateWarning;
@end

//
//  Utilities.h
//  Kickball
//
//  Created by Shawn Bernard on 12/10/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"

#define kCityRadiusKey @"cityRadius"
#define kLastLatitudeKey @"lastLatitude"
#define kLastLongitudeKey @"lastLongitude"
#define TWITTER_DISPLAY_DATE_FORMAT @"LLL dd, hh:mm a"

static const int CITY_RADIUS_INFINTE  = -1;
static const int CITY_RADIUS_TINY = 16093;
static const int CITY_RADIUS_SMALL = 40234;
static const int CITY_RADIUS_MEDIUM = 80467;
static const int CITY_RADIUS_LARGE = 106934;

// Salt for hash function. Can be any arbitrary value, but must be shared with server
#define kKBHashSalt @"33eBMKjsW9CTWpX4njEKarkWGoH9ZdzP"

@interface Utilities : NSObject {
    NSMutableArray *friendsWithPingOn;
    int runningTotalNumberOfUsersBeingPushed;
    int totalNumberOfUsersForPush;
    NSDateFormatter *foursquareCheckinDateFormatter;
    NSMutableString *ids;
    NSMutableArray *userIdsToReceivePings;
	NSAutoreleasePool *pool;
}

@property (nonatomic, retain) NSMutableArray *friendsWithPingOn;
@property (nonatomic, retain) NSDateFormatter *foursquareCheckinDateFormatter;
@property (nonatomic, retain) NSMutableArray *userIdsToReceivePings;

+ (Utilities *)sharedInstance;

- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImage: (NSString *) ImageURLString;
//- (UIImage *) roundCorners: (UIImage*) img;
//- (void) retrieveAllFriendsWithPingOn;
+ (void)putGoogleMapsWallPostWithMessage:(NSString*)message andVenue:(FSVenue*)venue andLink:(NSString*)link;
- (void) updateAllFriendsWithPingOn:(NSArray*)checkins;
+ (NSDate*) convertUTCCheckinDateToLocal:(NSDate*)utcDate;
+ (NSString*)safeString:(NSString*)fromString;
- (NSNumber*) getCityRadius;
- (void) setCityRadius:(int)meters;
+ (NSString*) shortenUrl:(NSString*)longUrl;
+ (NSString*) convertVenueToFoursquareUrl:(NSString*)venueId;
+ (NSString*) getShortenedUrlFromFoursquareVenueId:(NSString*)venueId;
+ (natural_t)getMemory;
- (void) updateFriendWithPingOn:(NSString*) friendId;

@end

//
//  Utilities.h
//  Kickball
//
//  Created by Shawn Bernard on 12/10/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

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
extern const NSString *kKBHashSalt;

@interface Utilities : NSObject {
    NSMutableArray *friendsWithPingOn;
    int runningTotalNumberOfUsersBeingPushed;
    int totalNumberOfUsersForPush;
    NSDateFormatter *foursquareCheckinDateFormatter;
    NSMutableString *ids;
    NSMutableArray *userIdsToReceivePings;
}

@property (nonatomic, retain) NSMutableArray *friendsWithPingOn;
@property (nonatomic, retain) NSDateFormatter *foursquareCheckinDateFormatter;
@property (nonatomic, retain) NSMutableArray *userIdsToReceivePings;

+ (Utilities *)sharedInstance;

- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImage: (NSString *) ImageURLString;
//- (UIImage *) roundCorners: (UIImage*) img;
- (void) retrieveAllFriendsWithPingOn;
- (void) updateAllFriendsWithPingOn;
+ (UIImage *)makeRoundCornerImage:(UIImage*)img cornerwidth:(int) cornerWidth cornerheight:(int) cornerHeight;
+ (NSDate*) convertUTCCheckinDateToLocal:(NSDate*)utcDate;
- (NSNumber*) getCityRadius;
- (void) setCityRadius:(int)meters;
+ (NSString*) shortenUrl:(NSString*)longUrl;
+ (NSString*) convertVenueToFoursquareUrl:(NSString*)venueId;
+ (NSString*) getShortenedUrlFromFoursquareVenueId:(NSString*)venueId;

@end

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

// Salt for hash function. Can be any arbitrary value, but must be shared with server
extern const NSString *kKBHashSalt;

@interface Utilities : NSObject {
    NSMutableArray *friendsWithPingOn;
    int runningTotalNumberOfUsersBeingPushed;
    int totalNumberOfUsersForPush;
    NSDateFormatter *foursquareCheckinDateFormatter;
}

@property (nonatomic, retain) NSMutableArray *friendsWithPingOn;
@property (nonatomic, retain) NSDateFormatter *foursquareCheckinDateFormatter;

+ (Utilities *)sharedInstance;

- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImage: (NSString *) ImageURLString;
//- (UIImage *) roundCorners: (UIImage*) img;
- (void) retrieveAllFriendsWithPingOn;
+ (UIImage *)makeRoundCornerImage:(UIImage*)img cornerwidth:(int) cornerWidth cornerheight:(int) cornerHeight;
+ (NSDate*) convertUTCCheckinDateToLocal:(NSDate*)utcDate;
- (NSNumber*) getCityRadius;

@end

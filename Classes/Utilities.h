//
//  Utilities.h
//  Kickball
//
//  Created by Shawn Bernard on 12/10/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Salt for hash function. Can be any arbitrary value, but must be shared with server
extern const NSString *kKBHashSalt;

@interface Utilities : NSObject {
    NSMutableArray *friendsWithPingOn;
    int runningTotalNumberOfUsersBeingPushed;
    int totalNumberOfUsersForPush;
}

@property (nonatomic, retain) NSMutableArray *friendsWithPingOn;

+ (Utilities *)sharedInstance;

- (void) cacheImage: (NSString *) ImageURLString;
- (UIImage *) getCachedImage: (NSString *) ImageURLString;
//- (UIImage *) roundCorners: (UIImage*) img;
- (void) retrieveAllFriendsWithPingOn;

@end

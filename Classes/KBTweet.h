//
//  KBTweet.h
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"


@interface KBTweet : NSObject {
    NSString *screenName;
    NSString *fullName;
    NSDate *createDate;
    NSString *profileImageUrl;
    NSString *tweetText;
    NSNumber *tweetId;
    NSDictionary *dict;
}

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) NSString *profileImageUrl;
@property (nonatomic, retain) NSString *tweetText;
@property (nonatomic, retain) NSNumber *tweetId;

- (id) initWithDictionary:(NSDictionary*)statusDictionary;

@end

//
//  KBTweet.h
//  Kickball
//
//  Created by Shawn Bernard on 4/18/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KBTweet : NSObject {
    NSString *screenName;
    NSDate *createDate;
    NSString *profileImageUrl;
    NSString *tweetText;
}

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) NSString *profileImageUrl;
@property (nonatomic, retain) NSString *tweetText;

- (id) initWithDictionary:(NSDictionary*)statusDictionary;

@end

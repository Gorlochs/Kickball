//
//  KBTwitterUser.m
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterUser.h"


@implementation KBTwitterUser

@synthesize screenName;
@synthesize fullName;
@synthesize profileImageUrl;
@synthesize userId;

- (id) initWithDictionary:(NSDictionary*)userDictionary {
    if (self = [super init]) {
        dict = [[NSDictionary alloc] initWithDictionary:userDictionary];
        screenName = [userDictionary objectForKey:@"screen_name"];
        fullName = [userDictionary objectForKey:@"name"];
        profileImageUrl = [userDictionary objectForKey:@"profile_image_url"];
        userId = [userDictionary objectForKey:@"id"];
//        createDate = [[NSDate dateWithTimeIntervalSince1970:[[statusDictionary objectForKey:@"created_at"] doubleValue]] retain];
    }
    return self;
}

@end

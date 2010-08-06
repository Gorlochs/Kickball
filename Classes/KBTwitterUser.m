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
        screenName =  [[userDictionary objectForKey:@"screen_name"] copy];
        fullName = [[userDictionary objectForKey:@"name"] copy];
        profileImageUrl = [[userDictionary objectForKey:@"profile_image_url"] copy];
        userId = [[userDictionary objectForKey:@"id"] copy];
    }
    return self;
}

-(void)dealloc{
	[screenName release];
	[fullName release];
	[profileImageUrl release];
	[userId release];
	[super	dealloc];
}

@end

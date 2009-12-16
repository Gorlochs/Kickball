//
//  FSUser.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSUser.h"


@implementation FSUser

@synthesize	userId, firstname, lastname, photo, gender, badges, isFriend, firstnameLastInitial, userCity, mayorOf;
@synthesize twitter, icon, checkin, friendStatus, isPingOn, sendToTwitter, sendToFacebook, sendsPingsToSignedInUser;

- (id)init {
    if ((self = [super init])) {
        friendStatus = FSStatusNotFriend;
    }
    return self;    
}

- (NSString*) firstnameLastInitial {
    if (lastname != nil) {
        return [NSString stringWithFormat:@"%@ %@.", firstname, [lastname substringToIndex:1]];
    } else {
        return firstname;
    }
}

- (NSString*) description {
    return [NSString stringWithFormat:@"(USER : userId=%@ ; firstname=%@ ; userCity=%@ ; photo=%@ ; pings=%d ; sendtotwitter=%d)", userId, firstname, userCity, photo, isPingOn, sendToTwitter];
}

@end

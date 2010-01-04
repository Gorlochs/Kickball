//
//  FSUser.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSUser.h"


@implementation FSUser

@synthesize	userId, firstname, lastname, photo, gender, badges, isFriend, firstnameLastInitial, userCity, mayorOf;
@synthesize twitter, icon, checkin, friendStatus, isPingOn, sendToTwitter, sendToFacebook, sendsPingsToSignedInUser, email, phone, facebook;

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

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: userId forKey:@"userId"]; 
    [coder encodeObject: firstname forKey:@"firstname"]; 
    [coder encodeObject: lastname forKey:@"lastname"]; 
    [coder encodeObject: photo forKey:@"photo"]; 
    [coder encodeObject: gender forKey:@"gender"]; 
    [coder encodeObject: badges forKey:@"badges"]; 
    [coder encodeBool: isFriend forKey:@"isFriend"]; 
    [coder encodeObject: userCity forKey:@"userCity"]; 
    [coder encodeObject: mayorOf forKey:@"mayorOf"]; 
    [coder encodeObject: twitter forKey:@"twitter"]; 
    [coder encodeObject: icon forKey:@"icon"]; 
    [coder encodeObject: checkin forKey:@"checkin"]; 
    [coder encodeInteger: friendStatus forKey:@"friendStatus"]; 
    [coder encodeBool: isPingOn forKey:@"isPingOn"]; 
    [coder encodeBool: sendToTwitter forKey:@"sendToTwitter"]; 
    [coder encodeBool: sendToFacebook forKey:@"sendToFacebook"]; 
    [coder encodeBool: sendsPingsToSignedInUser forKey:@"sendsPingsToSignedInUser"]; 
    [coder encodeObject: email forKey:@"email"]; 
    [coder encodeObject: phone forKey:@"phone"]; 
    [coder encodeObject: facebook forKey:@"facebook"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setUserId: [coder decodeObjectForKey:@"userId"]]; 
        [self setFirstname: [coder decodeObjectForKey:@"firstname"]];  
        [self setLastname: [coder decodeObjectForKey:@"lastname"]];  
        [self setPhoto: [coder decodeObjectForKey:@"photo"]]; 
        [self setGender: [coder decodeObjectForKey:@"gender"]]; 
        [self setBadges: [coder decodeObjectForKey:@"badges"]]; 
        [self setIsFriend: [coder decodeBoolForKey:@"isFriend"]]; 
        [self setUserCity: [coder decodeObjectForKey:@"userCity"]]; 
        [self setMayorOf: [coder decodeObjectForKey:@"mayorOf"]]; 
        [self setTwitter: [coder decodeObjectForKey:@"twitter"]]; 
        [self setIcon: [coder decodeObjectForKey:@"icon"]]; 
        [self setCheckin: [coder decodeObjectForKey:@"checkin"]]; 
        [self setFriendStatus: [coder decodeIntegerForKey:@"friendStatus"]]; 
        [self setIsPingOn: [coder decodeBoolForKey:@"isPingOn"]]; 
        [self setSendToTwitter: [coder decodeBoolForKey:@"sendToTwitter"]]; 
        [self setSendToFacebook: [coder decodeBoolForKey:@"sendToFacebook"]]; 
        [self setSendsPingsToSignedInUser: [coder decodeBoolForKey:@"sendsPingsToSignedInUser"]]; 
        [self setEmail: [coder decodeObjectForKey:@"email"]]; 
        [self setPhone: [coder decodeObjectForKey:@"phone"]]; 
        [self setFacebook: [coder decodeObjectForKey:@"facebook"]]; 
    } 
    return self; 
} 

@end

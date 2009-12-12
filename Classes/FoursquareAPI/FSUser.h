//
//  FSUser.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCity.h"

typedef enum {
	FSStatusFriend = 0,
	FSStatusNotFriend = 1,
    FSStatusPendingYou = 2,
    FSStatusPendingThem = 3
} FSFriendStatus;

@class FSCheckin;

@interface FSUser : NSObject {
	NSString * userId;
	NSString * firstname;
	NSString * lastname;
	NSString * photo;
	NSString * gender;
    NSString * twitter;
	NSArray * badges;
	NSArray * mayorOf;
    FSCity * userCity;
	BOOL isFriend;
    FSFriendStatus friendStatus;
    FSCheckin * checkin;
    
    // these are for the signed in user
    BOOL isPingOn;
    BOOL sendToTwitter;
    BOOL sendToFacebook;
    
    // this is for an 'other' user
    BOOL sendsPingsToSignedInUser;
    
    // convenience property
    NSString *firstnameLastInitial;
    UIImage *icon;
}

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSArray * badges;
@property (nonatomic, retain) NSArray * mayorOf;
@property (nonatomic, retain) FSCity * userCity;
@property (nonatomic, retain) FSCheckin * checkin;
@property (nonatomic) BOOL isFriend;
@property (nonatomic) BOOL isPingOn;
@property (nonatomic) BOOL sendToTwitter;
@property (nonatomic) BOOL sendToFacebook;
@property (nonatomic) BOOL sendsPingsToSignedInUser;
@property (nonatomic) FSFriendStatus friendStatus;

@property (nonatomic, retain) NSString * firstnameLastInitial;
@property (nonatomic, retain) UIImage *icon;


@end

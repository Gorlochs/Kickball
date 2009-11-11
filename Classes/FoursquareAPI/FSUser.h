//
//  FSUser.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCity.h"

@interface FSUser : NSObject {
	NSString * userId;
	NSString * firstname;
	NSString * lastname;
	NSString * photo;
	NSString * gender;
	NSArray * badges;
	NSArray * mayorOf;
    FSCity * userCity;
	BOOL isFriend;
    // convenience property
    NSString *firstnameLastInitial;
}

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSArray * badges;
@property (nonatomic, retain) NSArray * mayorOf;
@property (nonatomic, retain) FSCity * userCity;
@property (nonatomic) BOOL isFriend;
@property (nonatomic, retain) NSString * firstnameLastInitial;


@end

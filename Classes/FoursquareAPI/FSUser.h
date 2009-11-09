//
//  FSUser.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSUser : NSObject {
	NSString * userId;
	NSString * firstname;
	NSString * lastname;
	NSString * photo;
	NSString * gender;
	NSArray * badges;
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
@property (nonatomic) BOOL isFriend;
@property (nonatomic, retain) NSString * firstnameLastInitial;


@end

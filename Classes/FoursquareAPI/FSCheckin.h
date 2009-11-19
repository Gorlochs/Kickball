//
//  FSCheckin.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"
#import "FSUser.h"
#import "FSScoring.h"

@interface FSCheckin : NSObject {
	NSString * message;
	FSVenue * venue;
	NSArray * badges;
	NSArray * specials;
	NSString * created;
	NSString * checkinId;
	NSString * shout;
	NSString * display;
	FSUser * user;
	FSScoring * scoring;
}

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) FSVenue * venue;
@property (nonatomic, retain) NSArray * badges;
@property (nonatomic, retain) NSArray * specials;
@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSString * checkinId;
@property (nonatomic, retain) NSString * shout;
@property (nonatomic, retain) NSString * display;
@property (nonatomic, retain) FSUser * user;
@property (nonatomic, retain) FSScoring * scoring;
@end

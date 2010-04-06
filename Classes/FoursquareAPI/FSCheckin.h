//
//  FSCheckin.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSVenue.h"
#import "FSUser.h"
#import "FSMayor.h"
#import "FSScoring.h"

@interface FSCheckin : NSObject <NSCoding> {
	NSString * message;
	FSVenue * venue;
	NSArray * badges;
	NSArray * specials;
	NSString * created;
	NSString * checkinId;
	NSString * shout;
	NSString * display;
	FSUser * user; // not sure if this is supposed to represent the mayor or not
	FSMayor * mayor;
	FSScoring * scoring;
    BOOL isMayor; // is the checked in user the mayor?
    
    NSString *truncatedTimeUnits;
    NSString *truncatedTimeNumeral;
    NSInteger distanceFromLoggedInUser;
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
@property (nonatomic, retain) FSMayor * mayor;
@property (nonatomic) BOOL isMayor;
@property (nonatomic) NSInteger distanceFromLoggedInUser;

@property (nonatomic, retain) NSString * truncatedTimeUnits;
@property (nonatomic, retain) NSString * truncatedTimeNumeral;

- (NSDate*) convertUTCCheckinDateToLocal;

@end

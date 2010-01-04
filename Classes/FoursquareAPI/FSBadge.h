//
//  FSBadge.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSBadge : NSObject <NSCoding> {
	NSString * badgeId;
	NSString * badgeName;
	NSString * icon;
	NSString * badgeDescription;
}
@property (nonatomic, retain) NSString * badgeId;
@property (nonatomic, retain) NSString * badgeName;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * badgeDescription;

@end

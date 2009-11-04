//
//  FSBadge.h
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSBadge : NSObject {
	NSString * badgeId;
	NSString * badgeName;
	NSString * icon;
	NSString * description;
}
@property (nonatomic, retain) NSString * badgeId;
@property (nonatomic, retain) NSString * badgeName;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * description;

@end

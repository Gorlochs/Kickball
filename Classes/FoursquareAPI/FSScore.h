//
//  FSScore.h
//  Kickball
//
//  Created by David Evans on 11/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSScore : NSObject {
	int points;
	NSString * message;
	NSString * icon;
}

@property (nonatomic) int points;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * icon;

@end

//
//  FSScoring.h
//  Kickball
//
//  Created by David Evans on 11/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSScoring : NSObject {
	NSArray * scores;
	int total;
	NSString * message;
}

@property (nonatomic, retain) NSArray * scores;
@property (nonatomic) int total;
@property (nonatomic, retain) NSString * message;

@end

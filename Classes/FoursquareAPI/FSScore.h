//
//  FSScore.h
//  Kickball
//
//  Created by David Evans on 11/08/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSScore : NSObject <NSCoding> {
	NSInteger points;
	NSString * message;
	NSString * icon;
}

@property (nonatomic) NSInteger points;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * icon;

@end

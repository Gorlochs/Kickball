//
//  FSScoring.h
//  Kickball
//
//  Created by David Evans on 11/08/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSScoring : NSObject <NSCoding> {
	NSArray * scores;
	NSInteger total;
	NSString * message;
}

@property (nonatomic, retain) NSArray * scores;
@property (nonatomic) NSInteger total;
@property (nonatomic, retain) NSString * message;

@end

//
//  FSFunctionRequest.h
//  Kickball
//
//  Created by David Evans on 12/7/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSFunctionRequest : NSObject {
	SEL currentSelector;
	id  currentTarget;
	NSURL * currentRequestURL;
	NSMutableData * receivedData;
}
@property (nonatomic) SEL currentSelector;
@property (nonatomic, retain) id currentTarget;
@property (nonatomic, retain) NSURL * currentRequestURL;
@property (nonatomic, retain) NSMutableData * receivedData;

@end

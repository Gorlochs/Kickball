//
//  FSCity.h
//  Kickball
//
//  Created by David Evans on 11/10/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSCity : NSObject <NSCoding> {
	NSString * cityid;
	NSString * citytimezone;
	NSString * cityname;
}

@property (nonatomic, retain) NSString * cityid;
@property (nonatomic, retain) NSString * citytimezone;
@property (nonatomic, retain) NSString * cityname;
@end

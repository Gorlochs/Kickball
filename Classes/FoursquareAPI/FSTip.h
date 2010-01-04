//
//  FSTip.h
//  Kickball
//
//  Created by David Evans on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSUser.h"

@interface FSTip : NSObject <NSCoding> {
	FSUser * submittedBy;
	NSString * text;
	NSString * url;
	NSString * tipId;
}

@property (nonatomic, retain) FSUser * submittedBy;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * tipId;

@end

//
//  KBMessage.m
//  Kickball
//
//  Created by Shawn Bernard on 12/26/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBMessage.h"


@implementation KBMessage

@synthesize mainTitle, subtitle, message;

- (id) initWithMember: (NSString*)maintitle andSubtitle:(NSString*)subTitle andMessage:(NSString*)msg
{
    self = [super init];
    self.mainTitle = maintitle;
    self.subtitle = subTitle;
    self.message = msg;
    return self;
}

- (void) dealloc {
    [mainTitle release];
    [subtitle release];
    [message release];
    [super dealloc];
}


@end

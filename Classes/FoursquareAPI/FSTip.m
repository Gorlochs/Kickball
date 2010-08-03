//
//  FSTip.m
//  Kickball
//
//  Created by David Evans on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSTip.h"


@implementation FSTip

@synthesize submittedBy, text, url, tipId;

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: submittedBy forKey:@"submittedBy"]; 
    [coder encodeObject: text forKey:@"text"]; 
    [coder encodeObject: url forKey:@"url"]; 
    [coder encodeObject: tipId forKey:@"tipId"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setSubmittedBy: [coder decodeObjectForKey:@"submittedBy"]]; 
        [self setText:[coder decodeObjectForKey:@"text"]];  
        [self setUrl: [coder decodeObjectForKey:@"url"]];  
        [self setTipId: [coder decodeObjectForKey:@"tipId"]];  
    } 
    return self; 
} 

-(void)dealloc{
	[submittedBy release];
	[text release];
	[url release];
	[tipId release];
	[super dealloc];
}

@end

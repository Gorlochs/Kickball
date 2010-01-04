//
//  FSCity.m
//  Kickball
//
//  Created by David Evans on 11/10/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "FSCity.h"

@implementation FSCity

@synthesize cityid, citytimezone, cityname;

- (void) encodeWithCoder: (NSCoder *)coder { 
    [coder encodeObject: cityid forKey:@"cityid"]; 
    [coder encodeObject: citytimezone forKey:@"citytimezone"]; 
    [coder encodeObject: cityname forKey:@"cityname"]; 
} 

- (id) initWithCoder: (NSCoder *)coder { 
    if (self = [super init]) { 
        [self setCityid: [coder decodeObjectForKey:@"cityid"]]; 
        [self setCitytimezone:[coder decodeObjectForKey:@"citytimezone"]];  
        [self setCityname: [coder decodeObjectForKey:@"cityname"]];  
    } 
    return self; 
} 

@end

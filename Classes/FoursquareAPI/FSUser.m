//
//  FSUser.m
//  FSApi
//
//  Created by David Evans on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FSUser.h"


@implementation FSUser

@synthesize	userId,firstname,lastname,photo,gender, badges, isFriend, firstnameLastInitial;

- (NSString*) firstnameLastInitial {
    return [NSString stringWithFormat:@"%@ %@.", firstname, [lastname substringToIndex:1]];
}

@end

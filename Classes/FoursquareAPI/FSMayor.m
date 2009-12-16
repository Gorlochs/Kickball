//
//  FSMayor.m
//  Kickball
//
//  Created by Shawn Bernard on 12/15/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "FSMayor.h"


@implementation FSMayor

@synthesize user, mayorCheckinMessage, numCheckins, mayorTransitionType;

- (NSString*) description {
    return [NSString stringWithFormat:@"(MAYOR : user=%@ ; mayorCheckinMessage=%@ ; numCheckins=%d ; mayorTransitionType=%@)", user, mayorCheckinMessage, numCheckins, mayorTransitionType];
}

@end

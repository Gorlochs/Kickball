//
//  KBStats.h
//  Kickball
//
//  Created by Shawn Bernard on 3/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCheckin.h"

@interface KBStats : NSObject {

}

+ (KBStats*) stats;
- (void) checkinStat:(FSCheckin*)checkin;

@end

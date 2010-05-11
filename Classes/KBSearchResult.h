//
//  KBSearchResult.h
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBTweet.h"


@interface KBSearchResult : KBTweet {
    float latitude;
    float longitude;
}

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end

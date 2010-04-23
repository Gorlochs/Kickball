//
//  KBBaseTweetViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTwitterViewController.h"
#import "KBTweet.h"

@interface KBBaseTweetViewController : KBTwitterViewController <MGTwitterEngineDelegate> {
    NSMutableArray *tweets;
    NSString *cachingKey;
    int pageNum;
    NSArray *statuses;
    NSMutableArray *statusObjects;
}

- (void) showStatuses;

@end

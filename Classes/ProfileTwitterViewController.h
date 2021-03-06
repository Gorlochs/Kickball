//
//  ProfileTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface ProfileTwitterViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *tweets;
    NSMutableDictionary *orderedTweets;
    NSArray *sortedKeys;
}

@property (nonatomic, retain) NSArray *tweets;

NSInteger dateSort(id letter1, id letter2, void *dummy);

@end

//
//  KBTweetListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBTwitterViewController.h"
#import "TableItemTestController.h"


@interface KBTweetListViewController : KBTwitterViewController {
    NSArray *statuses;
    NSMutableArray *statusObjects;
    TableItemTestController *tableController;
    NSMutableArray *tweets;
}

- (void) loginSuccessful;

@end

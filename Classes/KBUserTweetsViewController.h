//
//  KBUserTweetsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTweetListViewController.h"


@interface KBUserTweetsViewController : KBTweetListViewController {
    NSString *username;
}

@property (nonatomic, retain) NSString *username;

@end

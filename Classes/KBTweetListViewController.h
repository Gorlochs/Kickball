//
//  KBTweetListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBBaseTweetViewController.h"
#import "KBTweet.h"
#import "KBTweetTableCell.h"
#import "KBTwitterXAuthLoginController.h"


@interface KBTweetListViewController : KBBaseTweetViewController {
    KBTwitterXAuthLoginController *loginController;
    BOOL _inModalTweetView;
    BOOL _firstView;
}

@end

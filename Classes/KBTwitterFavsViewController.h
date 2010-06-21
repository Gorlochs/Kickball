//
//  KBTwitterFavsViewController.h
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

@interface KBTwitterFavsViewController : KBBaseTweetViewController {
    KBTwitterXAuthLoginController *loginController;
    int displayType;
    NSDictionary *userDictionary;
    NSString *username;
    NSNumber *currentCursor;
}
@property (nonatomic, retain) NSDictionary *userDictionary;
@property (nonatomic, retain) NSString *username;

@end

//
//  KBTwitterSearchViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTweetListViewController.h"


@interface KBTwitterSearchViewController : KBTweetListViewController {
    NSString *searchTerms;
}

@property (nonatomic, retain) NSString *searchTerms;


@end

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
    IBOutlet UITableView *theTableView;
    
    NSArray *tweets;
    NSArray *sortedTweets;
}

@property (nonatomic, retain) NSArray *tweets;

- (IBAction) dismiss;
NSInteger dateSort(id letter1, id letter2, void *dummy);

@end

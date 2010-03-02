//
//  FriendSearchResultsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface FriendSearchResultsViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    NSArray *searchResults;
}

@property (nonatomic, retain) NSArray *searchResults;

@end

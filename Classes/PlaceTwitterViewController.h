//
//  PlaceTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngineDelegate.h"
#import "KBBaseViewController.h"


@interface PlaceTwitterViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, MGTwitterEngineDelegate> {
    NSString *twitterName;
    NSArray *twitterStatuses;
    NSString *venueName;
    IBOutlet UILabel *venueLabel;
    IBOutlet UITableView *theTableView;
}

@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *venueName;

@end

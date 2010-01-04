//
//  PlaceTwitterViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGTwitterEngineDelegate.h"

@interface PlaceTwitterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MGTwitterEngineDelegate> {
    NSString *twitterName;
    NSArray *twitterStatuses;
    NSString *venueName;
    IBOutlet UILabel *venueLabel;
    IBOutlet UITableView *theTableView;
}

@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *venueName;

- (IBAction) close;

@end

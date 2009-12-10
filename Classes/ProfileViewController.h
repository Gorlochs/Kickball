//
//  ProfileViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"
#import "KBBaseViewController.h"
#import "MGTwitterEngineDelegate.h"

@interface ProfileViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MGTwitterEngineDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *badgeCell;
    IBOutlet UITableViewCell *addFriendCell;
    IBOutlet UITableViewCell *friendActionCell;
    IBOutlet UITableView *twitterTable;
    NSString *userId;
    FSUser *user;
    NSArray *twitterStatuses;
    
    IBOutlet UILabel *name;
    IBOutlet UILabel *location;
    IBOutlet UILabel *lastCheckinAddress;
    IBOutlet UILabel *nightsOut;
    IBOutlet UILabel *totalCheckins;
    IBOutlet UIImageView *userIcon;
    IBOutlet UISegmentedControl *segmentedControl;
}

@property (nonatomic, retain) UITableViewCell *badgeCell;
@property (nonatomic, retain) NSString *userId;

- (IBAction) clickSegmentedControl;
- (IBAction) viewVenue;

@end

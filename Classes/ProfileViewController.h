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
#import "FSCheckin.h"

@interface ProfileViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MGTwitterEngineDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *badgeCell;
    IBOutlet UITableViewCell *addFriendCell;
    IBOutlet UITableViewCell *friendActionCell;
    IBOutlet UITableViewCell *friendPendingCell;
    IBOutlet UITableView *twitterTable;
    NSString *userId;
    FSUser *user;
    NSArray *twitterStatuses;
    NSArray *checkin;
    
    IBOutlet UILabel *name;
    IBOutlet UILabel *location;
    IBOutlet UILabel *lastCheckinAddress;
    IBOutlet UILabel *nightsOut;
    IBOutlet UILabel *totalCheckins;
    IBOutlet UIImageView *userIcon;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UIButton *pingsAndUpdates;
    
    // not sure what these are doing here
    bool isPingOn;
    bool isTwitterOn;
    
    bool isPingAndUpdatesOn;
    bool isDisplayingTwitter;
}

@property (nonatomic, retain) UITableViewCell *badgeCell;
@property (nonatomic, retain) NSString *userId;

- (IBAction) clickSegmentedControl;
- (IBAction) viewVenue;
- (IBAction) checkinToProfilesVenue;
- (IBAction) unfriend;
- (IBAction) togglePingsAndUpdates;
- (IBAction) friendUser;

@end

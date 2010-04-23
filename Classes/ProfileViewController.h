//
//  ProfileViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"
#import "KBFoursquareViewController.h"
#import "MGTwitterEngineDelegate.h"
#import "FSCheckin.h"
#import "BlackTableCellHeader.h"

@interface ProfileViewController : KBFoursquareViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MGTwitterEngineDelegate> {
    IBOutlet UITableViewCell *badgeCell;
    IBOutlet UITableViewCell *addFriendCell;
    IBOutlet UITableViewCell *friendActionCell;
    IBOutlet UITableViewCell *friendPendingCell;
    IBOutlet UITableViewCell *friendHistoryCell;
    IBOutlet UITableViewCell *friendHistorySplitCell;
    NSString *userId;
    FSUser *user;
    NSArray *twitterStatuses;
    NSArray *checkin;
    
    IBOutlet UILabel *name;
    IBOutlet UILabel *location;
    IBOutlet UILabel *lastCheckinAddress;
    IBOutlet UILabel *totalCheckins;
    IBOutlet UIImageView *userIcon;
    IBOutlet UIButton *pingsAndUpdates;
    IBOutlet UIButton *hereIAmButton;
    IBOutlet UIButton *locationOverlayButton;
    
    IBOutlet UIButton *textButton;
    IBOutlet UIButton *callButton;
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    
    // not sure what these are doing here
    bool isPingOn;
    bool isTwitterOn;
    
    bool isPingAndUpdatesOn;
    bool hasPhotos;
    
    NSMutableArray *userPhotos;
    IBOutlet UIView *profileOptionsView;
    IBOutlet UIView *profileInfoView;
    IBOutlet UITableViewCell *photoCell;
    IBOutlet UISwitch *checkinNotificationSwitch;
    IBOutlet UISwitch *photoNotificationSwitch;
    IBOutlet UIImageView *photoCorners;
}

@property (nonatomic, retain) UITableViewCell *badgeCell;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) FSUser *user;

- (void) setAllUserFields:(FSUser*)user;
- (void) displayActionSheet:(NSString*)title withTag:(NSInteger)tag;
- (IBAction) viewVenue;
- (IBAction) checkinToProfilesVenue;
- (IBAction) unfriend;
- (IBAction) togglePingsAndUpdates;
- (IBAction) friendUser;
- (IBAction) textProfile;
- (IBAction) callProfile;
- (IBAction) emailProfile;
- (IBAction) viewProfilesTwitterFeed;
- (IBAction) facebookProfile;
- (IBAction) viewHistory;
- (IBAction) viewProfilesFriends;
- (IBAction) viewYourPhotos;
- (void) retrieveUserPhotos;
- (IBAction) showProfileOptions;
- (IBAction) removeProfileOptions;
- (IBAction) showInfoOptions;
- (IBAction) removeInfoOptions;
- (void) executeFoursquareCalls;

@end

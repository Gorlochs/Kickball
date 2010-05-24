//
//  OptionsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"


@interface OptionsViewController : KBFoursquareViewController {
    IBOutlet UILabel *friendRequestCount;
    NSArray *pendingFriendRequests;
    
    IBOutlet UITableViewCell *defaultCheckinCell;
    IBOutlet UITableViewCell *friendsListPriorityCell;
    IBOutlet UITableViewCell *pushNotificationCell;
    IBOutlet UITableViewCell *accountInformationCell;
    IBOutlet UITableViewCell *feedbackCell;
    IBOutlet UITableViewCell *versionInformationsCell;
    
    IBOutlet UIButton *defaultCheckinButton;
    IBOutlet UIButton *friendsListPriorityButton;
    IBOutlet UISwitch *pushNotificationButton;
    IBOutlet UIButton *accountInformationButton;
    IBOutlet UIButton *feedbackButton;
    IBOutlet UIButton *versionInformationsButton;
    
    NSArray *cellArray;
}

- (IBAction) viewFriendRequests;
- (IBAction) addFriends;
- (IBAction) viewAccountOptions;
- (IBAction) viewVersion;
- (IBAction) viewFriendPriority;
- (IBAction) viewFeedback;
- (IBAction) viewDefaultCheckinOptions;

@end

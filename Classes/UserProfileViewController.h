//
//  UserProfileViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/14/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "FoursquareAPI.h"

@interface UserProfileViewController : ProfileViewController {
    IBOutlet UIButton *yourStuffButton;
    IBOutlet UIButton *yourFriendsButton;
    IBOutlet UIButton *checkinHistoryButton;
	
	IBOutlet UITableViewCell *friendToggleCell;
	IBOutlet UISegmentedControl *friendToggle;
    
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *mentionsButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *directMessageButton;

}

- (IBAction) displayStuff;
- (IBAction) displayFriends;
- (IBAction) displayCheckinHistory;

@end

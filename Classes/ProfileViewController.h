//
//  ProfileViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *badgeCell;
    NSString *userId;
    FSUser *user;
    
    IBOutlet UILabel *nameLocation;
    IBOutlet UILabel *lastCheckinAddress;
    IBOutlet UILabel *nightsOut;
    IBOutlet UILabel *totalCheckins;
    IBOutlet UIImageView *userIcon;
}

@property (nonatomic, retain) UITableViewCell *badgeCell;
@property (nonatomic, retain) NSString *userId;

@end

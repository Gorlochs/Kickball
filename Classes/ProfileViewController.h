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
    IBOutlet UITableViewCell *titleCell;
    NSString *userId;
    FSUser *user;
}

@property (nonatomic, retain) UITableViewCell *titleCell;
@property (nonatomic, retain) NSString *userId;

@end

//
//  KBTwitterProfileViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBTwitterViewController.h"
#import "IFTweetLabel.h"


@interface KBTwitterProfileViewController : KBTwitterViewController {
    IBOutlet UILabel *screenNameLabel;
    IBOutlet UILabel *fullName;
    IBOutlet UILabel *location;
    IBOutlet UILabel *numberOfFollowers;
    IBOutlet UILabel *numberOfFriends;
    IFTweetLabel *description;
    
    NSString *screenname;
}

@property (nonatomic, retain) NSString *screenname;

@end

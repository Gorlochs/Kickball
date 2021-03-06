//
//  FriendPriorityOptionViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsVC.h"


@interface FriendPriorityOptionViewController : OptionsVC {
    IBOutlet UISlider *slider;
	IBOutlet UIImageView *detailText;
}

- (IBAction) nextOptionView;
- (IBAction) releasedSlider;

@end

//
//  FriendPriorityOptionViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"


@interface FriendPriorityOptionViewController : KBFoursquareViewController {
    IBOutlet UISlider *slider;
}

- (IBAction) nextOptionView;

@end

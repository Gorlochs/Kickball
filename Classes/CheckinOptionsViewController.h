//
//  CheckinOptionsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsVC.h"


@interface CheckinOptionsViewController : OptionsVC {
    IBOutlet UISwitch *foursquareSwitch;
    IBOutlet UISwitch *twitterSwitch;
    IBOutlet UISwitch *facebookSwitch;
}

- (IBAction) nextOptionView;
- (IBAction) toggleFoursquare;
- (IBAction) toggleFacebook;
- (IBAction) toggleTwitter;

@end

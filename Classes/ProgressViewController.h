//
//  ProgressViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/22/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {
    IBOutlet UIImageView *stripedActivityIndicator;
    IBOutlet UILabel *activityLabel;
}

@property (nonatomic, retain) UILabel *activityLabel;

- (void) setupBusyAnimation;

@end

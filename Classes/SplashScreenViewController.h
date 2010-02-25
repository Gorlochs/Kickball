//
//  SplashScreenViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 2/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplashScreenViewController : UIViewController {
    IBOutlet UIImageView *splashView;
}

- (void) setupSplashAnimation;

@end

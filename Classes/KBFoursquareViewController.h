//
//  KBFoursquareViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"

@class KBFoursquareLoginView;
@interface KBFoursquareViewController : KBBaseViewController {
    
    IBOutlet UIButton *friendButton;
    IBOutlet UIButton *placesButton;
    IBOutlet UIButton *centerHeaderButton;
    IBOutlet UIButton *homeButton;
    IBOutlet UIButton *backButton;
	KBFoursquareLoginView *fsLoginView;
}

- (IBAction) flipBetweenMapAndList;
- (IBAction) viewPlaces;
- (IBAction) viewFriends;
- (IBAction) backOneView;
- (IBAction) backOneViewNotAnimated;
- (IBAction) goToHomeView;
- (IBAction) goToHomeViewNotAnimated;
- (void) showBackHomeButtons;

-(void)showLoginView;
-(void)killLoginView;

@end

@interface KBFoursquareViewController (Private)

- (void) setProperFoursquareButtons;

@end

//
//  KBFacebookViewController.h
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "KBFacebookLoginView.h"
#import "KBFoursquareViewController.h"

@interface KBFacebookViewController : KBBaseViewController {

	IBOutlet UIButton *friendButton;
    IBOutlet UIButton *eventButton;
    IBOutlet UIButton *centerHeaderButton;
    IBOutlet UIButton *homeButton;
    IBOutlet UIButton *backButton;
    
    UIView *facebookHeaderView;
	KBFacebookLoginView *fbLoginView;

	//do I need these?
	int pageNum;
}

//- (IBAction) flipBetweenMapAndList;
- (IBAction) viewEvents;
- (IBAction) viewFriends;
- (IBAction) backOneView;
- (IBAction) backOneViewNotAnimated;
- (IBAction) goToHomeView;
- (IBAction) goToHomeViewNotAnimated;
- (void) showBackHomeButtons;

- (IBAction) openStatusModalView;

-(void)showLoginView;
-(void)killLoginView;

@end
@interface KBFacebookViewController (Private)

- (void) setProperFacebookButtons;

@end


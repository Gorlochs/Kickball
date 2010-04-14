//
//  KBFoursquareViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"

typedef enum{
	KBPageTypeFriends = 0,
	KBPageTypePlaces,
	KBPageTypeOther,	
} KBPageType;

typedef enum{
	KBPageViewTypeList = 0,
	KBPageViewTypeMap,
	KBPageViewTypeOther,	
} KBPageViewType;

@interface KBFoursquareViewController : KBBaseViewController {
    KBPageType pageType;
    KBPageViewType pageViewType;
    
    IBOutlet UIButton *friendButton;
    IBOutlet UIButton *placesButton;
    IBOutlet UIButton *centerHeaderButton;
}

- (IBAction) flipBetweenMapAndList;
- (IBAction) viewPlacesList;
- (IBAction) viewFriendsList;
- (IBAction) backOneView;
- (IBAction) backOneViewNotAnimated;
- (IBAction) goToHomeView;
- (IBAction) goToHomeViewNotAnimated;

@end

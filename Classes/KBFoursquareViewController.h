//
//  KBFoursquareViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/12/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface KBFoursquareViewController : KBBaseViewController {

}

- (IBAction) viewFriendsMap;
- (IBAction) viewPlacesMap;
- (IBAction) viewPlacesList;
- (IBAction) viewFriendsList;
- (IBAction) backOneView;
- (IBAction) backOneViewNotAnimated;
- (IBAction) goToHomeView;
- (IBAction) goToHomeViewNotAnimated;

@end

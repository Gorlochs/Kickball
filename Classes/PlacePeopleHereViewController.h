//
//  PlacePeopleHereViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFacebookViewController.h"


@interface PlacePeopleHereViewController : AbstractFacebookViewController {
    NSArray *checkedInUsers;
}

@property (nonatomic, retain) NSArray *checkedInUsers;

@end

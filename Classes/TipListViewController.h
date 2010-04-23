//
//  TipListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"
#import "FSVenue.h"


@interface TipListViewController : KBFoursquareViewController {
    FSVenue *venue;
}

@property (nonatomic, retain) FSVenue *venue;

@end

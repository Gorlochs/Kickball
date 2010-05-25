//
//  TipListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBFoursquareViewController.h"
#import "FSVenue.h"
#import "TipDetailViewController.h"


@interface TipListViewController : KBFoursquareViewController {
    FSVenue *venue;
    TipDetailViewController *tipController;
}

@property (nonatomic, retain) FSVenue *venue;

@end

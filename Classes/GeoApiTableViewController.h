//
//  GeoApiTableViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"

@interface GeoApiTableViewController : KBFoursquareViewController {
    NSArray *geoAPIResults;
}

@property (nonatomic, retain) NSArray *geoAPIResults;

@end

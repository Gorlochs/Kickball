//
//  GeoApiDetailsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "GAConnectionDelegate.h"
#import "GAPlace.h"


@interface GeoApiDetailsViewController : KBBaseViewController <GAConnectionDelegate, UITableViewDelegate, UITableViewDataSource> {
    GAPlace *place;
    
    IBOutlet UITableView *theTableView;
}

@property (nonatomic, retain) GAPlace *place;

@end

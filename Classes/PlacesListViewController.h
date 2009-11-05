//
//  PlacesListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface PlacesListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *searchCell;
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    NSArray *venues;
}

@property (nonatomic, retain) UITableViewCell *searchCell;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) NSArray *venues;

@end

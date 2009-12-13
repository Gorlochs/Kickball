//
//  PlacesListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KBBaseViewController.h"

typedef enum {
	KBNearbyVenues = 0,
	KBSearchVenues = 1
} KBListType;

@interface PlacesListViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *searchCell;
    IBOutlet UITextField *searchbox;
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    NSDictionary *venues;
    KBListType venuesTypeToDisplay;
}

@property (nonatomic, retain) UITableViewCell *searchCell;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) NSDictionary *venues;

- (IBAction) searchOnKeywordsandLatLong;
- (IBAction) flipToMap;
- (IBAction) refresh;
- (IBAction) addNewVenue;

@end

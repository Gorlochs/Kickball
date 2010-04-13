//
//  PlacesListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/30/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KBBaseViewController.h"

typedef enum {
	KBNearbyVenues = 0,
	KBSearchVenues = 1
} KBListType;

@interface PlacesListViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UITableViewCell *searchCell;
    IBOutlet UITextField *searchbox;
    IBOutlet UITableViewCell *footerCell;
    NSDictionary *venues;
    KBListType venuesTypeToDisplay;
    bool isSearchEmpty;
}

@property (nonatomic, retain) UITableViewCell *searchCell;
@property (nonatomic, retain) NSDictionary *venues;

- (IBAction) searchOnKeywordsandLatLong;
- (IBAction) flipToMap;
- (IBAction) refresh: (UIControl *) button;
- (IBAction) addNewVenue;
- (IBAction) cancelKeyboard: (UIControl *) button;
- (IBAction) cancelTheKeyboard;
- (IBAction) cancelEdit;

@end

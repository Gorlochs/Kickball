//
//  AddPlaceViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KBBaseViewController.h"
#import "FSVenue.h"

@interface AddPlaceViewController : KBBaseViewController <MKMapViewDelegate> {
    IBOutlet UILabel *newPlaceName;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *addCategoryButton;
    IBOutlet UIButton *addAddressButton;
    IBOutlet UILabel *addressNotation;
    IBOutlet UILabel *categoryNotation;
    NSString *newVenueName;
    NSString *categoryId;
    FSVenue *venue;
    
    NSArray *checkin;
}

@property (nonatomic, retain) NSArray *checkin;
@property (nonatomic, retain) NSString *newVenueName;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) FSVenue *venue;

//- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath;
//- (IBAction) checkinToNewVenue;
//- (IBAction) switchToTextFields;
- (IBAction) doVenuelessCheckin;
- (IBAction) addAddress;
- (IBAction) addCategory;
- (IBAction) backOneView;
- (IBAction) saveVenueAndCheckin;

@end

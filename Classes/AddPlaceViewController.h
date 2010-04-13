//
//  AddPlaceViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "FSVenue.h"

@interface AddPlaceViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UITextField *newPlaceName;
    
    IBOutlet UITableViewCell *noneOfTheseCell;
    
    NSArray *checkin;
    NSDictionary *venues;
}

@property (nonatomic, retain) NSArray *checkin;

- (FSVenue*) extractVenueFromDictionaryForRow:(NSIndexPath*)indexPath;
- (IBAction) checkinToNewVenue;
- (IBAction) viewTipsForAddingNewPlace;
- (IBAction) switchToTextFields;
- (IBAction) checkListings;
- (IBAction) doVenuelessCheckin;

@end

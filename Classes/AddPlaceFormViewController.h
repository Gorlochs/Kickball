//
//  AddPlaceFormViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/14/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"
#import "FSVenue.h"

@interface AddPlaceFormViewController : KBFoursquareViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableViewCell *tableCell;
       
    IBOutlet UITextField *address;
    IBOutlet UITextField *crossstreet;
    IBOutlet UITextField *city;
    IBOutlet UITextField *state;
    IBOutlet UITextField *zip;
    IBOutlet UITextField *phone;
    IBOutlet UITextField *twitter;
    IBOutlet UITextField *country;
    
    IBOutlet UILabel *venueName;
    
    IBOutlet UIToolbar *toolbar;
    
    FSVenue *newVenue;
    
    CGFloat animatedDistance;
}

@property (nonatomic, retain) FSVenue *newVenue;
//@property (nonatomic, retain) NSString *city;
//@property (nonatomic, retain) NSString *state;

- (IBAction) clearFields;
//- (IBAction) saveVenueAndCheckin;
- (IBAction) cancelEditing;
- (IBAction) editNextField;
- (IBAction) editPreviousField;
- (IBAction) backToAddAVenue;
//- (void) newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

//
//  AddPlaceFormViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/14/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface AddPlaceFormViewController : KBBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    IBOutlet UITableViewCell *tableCell;
    NSString *newVenueName;
    
    IBOutlet UITextField *address;
    IBOutlet UITextField *crossstreet;
    IBOutlet UITextField *city;
    IBOutlet UITextField *state;
    IBOutlet UITextField *zip;
    IBOutlet UITextField *phone;
    IBOutlet UITextField *twitter;
    IBOutlet UITextField *placeName;
    
    IBOutlet UILabel *venueName;
    
    IBOutlet UIToolbar *toolbar;
    
    CGFloat animatedDistance;
}

@property (nonatomic, retain) NSString *newVenueName;
//@property (nonatomic, retain) NSString *city;
//@property (nonatomic, retain) NSString *state;

- (IBAction) clearFields;
- (IBAction) saveVenueAndCheckin;
- (IBAction) viewTipsForAddingNewPlace;
- (IBAction) cancelEditing;
- (IBAction) editNextField;
- (IBAction) editPreviousField;
- (void) newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

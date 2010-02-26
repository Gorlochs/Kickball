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
    
    IBOutlet UILabel *venueName;
    
    CGFloat animatedDistance;
}

@property (nonatomic, retain) NSString *newVenueName;

- (IBAction) clearFields;
- (IBAction) saveVenueAndCheckin;
- (IBAction) viewTipsForAddingNewPlace;
- (void) newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

//
//  AddPlaceFormViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/14/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface AddPlaceFormViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UITableView *theTableView;
    NSString *newVenueName;
    
    IBOutlet UITableViewCell *addressCell;
    IBOutlet UITableViewCell *crossstreetCell;
    IBOutlet UITableViewCell *cityCell;
    IBOutlet UITableViewCell *phoneCell;
    IBOutlet UITableViewCell *twitterCell;
    IBOutlet UITableViewCell *saveCell;
    IBOutlet UITableViewCell *checkedInCell;
    
    IBOutlet UITextField *address;
    IBOutlet UITextField *crossstreet;
    IBOutlet UITextField *city;
    IBOutlet UITextField *state;
    IBOutlet UITextField *zip;
    IBOutlet UITextField *phone;
    IBOutlet UITextField *twitter;
    
    CGFloat animatedDistance;
}

@property (nonatomic, retain) NSString *newVenueName;

- (IBAction) clearFields;
- (IBAction) saveVenueAndCheckin;
- (IBAction) doVenuelessCheckin;
- (void)newVenueResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

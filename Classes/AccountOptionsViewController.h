//
//  AccountOptionsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface AccountOptionsViewController : KBBaseViewController <UITextFieldDelegate> {
    IBOutlet UITableViewCell *foursquareCell;
    IBOutlet UITableViewCell *twitterCell;
    IBOutlet UITableViewCell *facebookCell;
    IBOutlet UIImageView *whyThisImage;
    
    IBOutlet UITextField *foursquareUsername;
    IBOutlet UITextField *foursquarePassword;
    IBOutlet UITextField *twitterUsername;
    IBOutlet UITextField *twitterPassword;
    
    IBOutlet UISwitch *kickballAccountLinkingSwitch;
    IBOutlet UISwitch *twitterGeotaggingSwitch;
    IBOutlet UISwitch *postPhotosToFacebookSwitch;
    
    IBOutlet UIButton *whatIsThisButton;
}

- (IBAction) authenticateFoursquare;
- (IBAction) authenticateTwitter;
- (IBAction) linkKickballAccount;
- (IBAction) enableTwitterGeotagging;
- (IBAction) postPhotosToFacebook;
- (IBAction) displayWhatsThis;

@end

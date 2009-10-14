//
//  SettingsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UIViewController <UITextFieldDelegate> {
    UITextField *username;
    UITextField *password;
}

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;

- (IBAction) submitUser;

@end

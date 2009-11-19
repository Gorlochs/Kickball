//
//  KBBaseViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBBaseViewController : UIViewController {
    IBOutlet UIButton *signedInUserIcon;
}

- (IBAction) backOneView;
- (IBAction) viewUserProfile;

@end

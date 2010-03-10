//
//  PopupMessageView.h
//  Kickball
//
//  Created by Shawn Bernard on 12/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBMessage.h"

@interface PopupMessageView : UIViewController {
    KBMessage *message;
    IBOutlet UILabel *messageTitle;
    //IBOutlet UILabel *subtitle;
    IBOutlet UILabel *messageText;
    IBOutlet UIButton *closeButton;
}

@property (nonatomic, retain) KBMessage *message;

- (IBAction) dismissPopupMessage;

@end

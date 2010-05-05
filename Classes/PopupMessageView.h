//
//  PopupMessageView.h
//  Kickball
//
//  Created by Shawn Bernard on 12/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBMessage.h"
#import "IFTweetLabel.h"

@interface PopupMessageView : UIViewController {
    KBMessage *message;
    IFTweetLabel *messageLabel;
    IBOutlet UIButton *closeButton;
    IBOutlet UIView *shadowBG;
    IBOutlet UILabel *titleLabel;
}

@property (nonatomic, retain) KBMessage *message;

- (IBAction) dismissPopupMessage;

@end

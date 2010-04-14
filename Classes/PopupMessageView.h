//
//  PopupMessageView.h
//  Kickball
//
//  Created by Shawn Bernard on 12/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "KBMessage.h"

@interface PopupMessageView : TTViewController {
    KBMessage *message;
    TTStyledTextLabel *mainLabel;
    IBOutlet UIButton *closeButton;
    IBOutlet UIView *shadowBG;
}

@property (nonatomic, retain) KBMessage *message;

- (IBAction) dismissPopupMessage;

@end

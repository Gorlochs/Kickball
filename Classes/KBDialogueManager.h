//
//  KBDialogueManager.h
//  Kickball
//
//  Created by scott bates on 7/15/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IFTweetLabel, KBMessage;
@interface KBDialogueManager : NSObject {
	int messageCount;
	IFTweetLabel *messageLabel;
	UIView *view;
	UILabel *titleLabel;
	UIButton *closeButton;
}

+ (KBDialogueManager*)sharedInstance;

- (void) displayMessage:(KBMessage*)message;
- (void) displayMessageWithAutoFade:(KBMessage *)message;
-(void)populateWithMessage:(KBMessage*)message;

-(void) fadeOut;
@end

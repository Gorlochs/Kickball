//
//  UIAlertViewHelper.m
//  CocoaHelpers
//
//  Created by Shaun Harrison on 10/16/08.
//  Copyright 2008 enormego. All rights reserved.
//

#import "UIAlertView+Helper.h"
#import "KBMessage.h"
#import "KBDialogueManager.h"


void UIAlertViewQuick(NSString* title, NSString* message, NSString* dismissButtonTitle) {
    KBMessage *theMessage = [[KBMessage alloc] initWithMember:title andMessage:message];
	[[KBDialogueManager sharedInstance] displayMessage:theMessage];
    [theMessage release];
}


@implementation UIAlertView (Helper)

@end

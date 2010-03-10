//
//  PopupMessageView.m
//  Kickball
//
//  Created by Shawn Bernard on 12/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "PopupMessageView.h"


@implementation PopupMessageView

@synthesize message;

- (void) viewDidLoad {
    [super viewDidLoad];
    messageTitle.text = message.mainTitle;
    
    CGSize maximumLabelSize = CGSizeMake(237,63);
    CGSize expectedLabelSize = [message.message sizeWithFont:messageText.font 
                                           constrainedToSize:maximumLabelSize 
                                               lineBreakMode:messageText.lineBreakMode]; 
    
    //adjust the label the the new height.
    CGRect newFrame = messageText.frame;
    newFrame.size.height = expectedLabelSize.height;
    messageText.frame = newFrame;
    
    messageText.text = message.message; // yikes, this is one scary line of code. I couldn't have done this on purpose.
}

- (void)dealloc {
    [message release];
    [messageTitle release];
    [messageText release];
    [closeButton release];
    [super dealloc];
}

- (void) dismissPopupMessage {
    [self.view removeFromSuperview];
}

@end

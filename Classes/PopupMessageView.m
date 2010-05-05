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
    
    messageLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20.0f, 135.0f, 280.0f, 220.0f)];
    [messageLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [messageLabel setTextColor:[UIColor whiteColor]];
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    [messageLabel setNumberOfLines:0];
    messageLabel.text = message.message;
    [self.view addSubview:messageLabel];
    
    titleLabel.text = message.mainTitle;
    
    NSLog(@"message: %@", message.message);
    CGSize maximumLabelSize = CGSizeMake(280, 220);
    CGSize expectedLabelSize = [message.message sizeWithFont:messageLabel.font 
                                           constrainedToSize:maximumLabelSize 
                                               lineBreakMode:UILineBreakModeClip]; 
    
    //adjust the label the the new height.
    CGRect newFrame = messageLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    NSLog(@"frame height: %f", self.view.frame.size.height);
    NSLog(@"label height: %f", expectedLabelSize.height);
    newFrame.origin.y = self.view.frame.size.height - expectedLabelSize.height - 20;
    messageLabel.frame = newFrame;
    
    CGRect newTitleFrame = titleLabel.frame;
    newTitleFrame.origin.y = newFrame.origin.y - 55;
    titleLabel.frame = newTitleFrame;
    [self.view bringSubviewToFront:titleLabel];
    
    if (message.isError) {
        titleLabel.textColor = [UIColor redColor];
    }
}

- (void) dismissPopupMessage {
    [self.view removeFromSuperview];
}

- (void)dealloc {
    [titleLabel release];
    [messageLabel release];
    [message release];
    [closeButton release];
    [super dealloc];
}

@end

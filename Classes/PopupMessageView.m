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
    subtitle.text = message.subtitle;
    text.text = message.message; // yikes, this is one scary line of code. I couldn't have done this on purpose.
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [message release];
    [messageTitle release];
    [subtitle release];
    [text release];
    [closeButton release];
    [super dealloc];
}

- (void) dismissPopupMessage {
    [self.view removeFromSuperview];
}

@end

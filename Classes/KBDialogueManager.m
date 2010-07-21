//
//  KBDialogueManager.m
//  Kickball
//
//  Created by scott bates on 7/15/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBDialogueManager.h"
#import "KBMessage.h"
#import "IFTweetLabel.h"

static KBDialogueManager* dialogue;

@implementation KBDialogueManager

@synthesize keyboardIsShowing;

- (id)init{
	if( (self = [super init])){
		messageCount = 0;
		UIWindow* keywindow = [[UIApplication sharedApplication] keyWindow];
		view = [[UIView alloc] initWithFrame:[keywindow frame]];
		view.backgroundColor = [UIColor blackColor];
		view.alpha = 0.85;
		view.opaque = NO;
		
		messageLabel = [[IFTweetLabel alloc] initWithFrame:CGRectMake(20.0f, 135.0f, 280.0f, 220.0f)];
		[messageLabel setFont:[UIFont systemFontOfSize:14.0f]];
		[messageLabel setTextColor:[UIColor whiteColor]];
		[messageLabel setBackgroundColor:[UIColor clearColor]];
		[messageLabel setNumberOfLines:0];
		[view addSubview:messageLabel];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 86, 291, 60)];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:42]];
		[titleLabel setTextColor:[UIColor colorWithRed:14/255.0 green:140/255.0 blue:192/255.0 alpha:1]];
		[titleLabel setNumberOfLines:1];
		[titleLabel setMinimumFontSize:10];
		titleLabel.adjustsFontSizeToFitWidth = YES;
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[view addSubview:titleLabel];
		
		closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[closeButton setFrame:view.bounds];
		[closeButton addTarget:self action:@selector(fadeOut) forControlEvents:UIControlEventTouchUpInside];
		[view addSubview:closeButton];
				
		return self;
	}
	
	return nil;
}

-(void)populateWithMessage:(KBMessage*)message{
	titleLabel.text = message.mainTitle;
	messageLabel.text = message.message;

	DLog(@"message: %@", message.message);
	CGSize maximumLabelSize = CGSizeMake(280, 220);
	CGSize expectedLabelSize = [message.message sizeWithFont:messageLabel.font 
										   constrainedToSize:maximumLabelSize 
											   lineBreakMode:UILineBreakModeClip]; 
	
	//adjust the label the the new height.
	CGRect newFrame = messageLabel.frame;
	newFrame.size.height = expectedLabelSize.height;
	DLog(@"frame height: %f", view.frame.size.height);
	DLog(@"label height: %f", expectedLabelSize.height);
	newFrame.origin.y = view.frame.size.height - expectedLabelSize.height - 20;
    if (keyboardIsShowing) newFrame.origin.y -= 300;
	messageLabel.frame = newFrame;
	
	CGRect newTitleFrame = titleLabel.frame;
	newTitleFrame.origin.y = newFrame.origin.y - 55;
	titleLabel.frame = newTitleFrame;
	[view bringSubviewToFront:titleLabel];
	
	if (message.isError) {
		titleLabel.textColor = [UIColor redColor];
	}else {
		[titleLabel setTextColor:[UIColor colorWithRed:14/255.0 green:140/255.0 blue:192/255.0 alpha:1]];
	}

	
	
}

- (void) displayMessage:(KBMessage*)message{
	messageCount++;
	[self populateWithMessage:message];
	if(messageCount == 1){
		view.alpha = 0;
		[[[UIApplication sharedApplication] keyWindow] addSubview:view];
		[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:view];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.7];
		view.alpha = 0.85;
		[UIView commitAnimations];
	}else {
		[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:view];
	}
	
}
		


- (void) displayMessageWithAutoFade:(KBMessage *)message{
    [self stopProgressBar];
	[self displayMessage:message];
	[self performSelector:@selector(fadeOut) withObject:nil afterDelay:3.0f];
}

-(void) fadeOut{
	messageCount=0;
	if (messageCount==0) {
		[UIView beginAnimations:@"fadeOut" context:NULL];
		[UIView setAnimationDuration:0.7];
		[UIView setAnimationDelegate:self];
		view.alpha = 0.0;
		[UIView commitAnimations];
	}
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:@"fadeOut"]) {
		[view removeFromSuperview];
	}
}


+ (KBDialogueManager*)sharedInstance{
	if(!dialogue){
		dialogue =[[KBDialogueManager alloc] init];
	}
	return dialogue;
}


- (void)dealloc{
	[messageLabel release];
	[titleLabel release];
	[view release];
	
	[super dealloc];
}

@end

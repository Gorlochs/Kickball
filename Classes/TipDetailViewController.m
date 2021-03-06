//
//  TipDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "TipDetailViewController.h"
#import "FoursquareAPI.h"


@implementation TipDetailViewController

@synthesize tip, venue;


- (void) markTipAsTodoForUser {
    [self startProgressBar:@"Marking tip as a todo..."];
    [[FoursquareAPI sharedInstance] markTipAsDone:tip.tipId withTarget:self andAction:@selector(tipTodoResponseReceived:withResponseString:)];
}

- (void) markTipAsDoneForUser {
    [self startProgressBar:@"Marking tip as done..."];
    [[FoursquareAPI sharedInstance] markTipAsTodo:tip.tipId withTarget:self andAction:@selector(tipResponseReceived:withResponseString:)];
}

- (void) tipResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"tip response string: %@", inString);
	NSString *tipId =  [FoursquareAPI tipIdFromResponseXML:inString];
    [self stopProgressBar];
    DLog(@"returned tip id: %@", tipId);
    if (tipId != nil) {
        // display thank you message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Tips" andMessage:@"Thanks for the tip! Maybe someone will one day say they've done this."];
        [self displayPopupMessage:message];
        [message release];
    } else {
        // display error message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Tips" andMessage:@"Something went wrong. Give it another try."];
        [self displayPopupMessage:message];
        [message release];
    }
}

- (void) tipTodoResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"tip response string: %@", inString);
	NSString *tipId =  [FoursquareAPI tipIdFromResponseXML:inString];
    [self stopProgressBar];
    DLog(@"returned tip id: %@", tipId);
    if (tipId != nil) {
        // display thank you message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Tips" andMessage:@"What are you waiting for? Do it!"];
        [self displayPopupMessage:message];
        [message release];
    } else {
        // display error message
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Tips" andMessage:@"Something went wrong. Give it another try."];
        [self displayPopupMessage:message];
        [message release];
    }
}

- (void) removeView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    self.view.alpha = 0;
    [UIView commitAnimations];
}

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideHeader = YES;
    [super viewDidLoad];
    
    authorNameLabel.text = [NSString stringWithFormat:@"%@ says,", tip.submittedBy.firstnameLastInitial];
    venueName.text = venue.name;
    venueAddress.text = venue.venueAddress;
	
	tipText.font = [UIFont systemFontOfSize:14.0];
	tipText.textColor = [UIColor colorWithRed:0.0 green:86.0/255.0 blue:136.0/255.0 alpha:1.0];
    
    //CGSize maximumLabelSize = CGSizeMake(259,91);
//    CGSize expectedLabelSize = [tip.text sizeWithFont:tipText.font 
//                                    constrainedToSize:maximumLabelSize 
//                                        lineBreakMode:tipText.lineBreakMode]; 
//    
//    //adjust the label the the new height.
//    CGRect newFrame = tipText.frame;
//    newFrame.size.height = expectedLabelSize.height;
//    tipText.frame = newFrame;
    
    tipText.text = tip.text;
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
    [tip release];
    [venue release];
    [authorNameLabel release];
    [tipText release];
    [venueName release];
    [venueAddress release];
    
    [super dealloc];
}


@end


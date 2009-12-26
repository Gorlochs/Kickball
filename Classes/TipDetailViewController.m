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
    [[FoursquareAPI sharedInstance] markTipAsDone:tip.tipId withTarget:self andAction:@selector(tipResponseReceived:withResponseString:)];
}

- (void) markTipAsDoneForUser {
    [[FoursquareAPI sharedInstance] markTipAsTodo:tip.tipId withTarget:self andAction:@selector(tipResponseReceived:withResponseString:)];
}

- (void) tipResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"tip response string: %@", inString);
	NSString *tipId =  [FoursquareAPI tipIdFromResponseXML:inString];
    NSLog(@"returned tip id: %@", tipId);
    if (tipId != nil) {
        // display thank you message
    } else {
        // display error message
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    authorNameLabel.text = [NSString stringWithFormat:@"%@ says,", tip.submittedBy.firstnameLastInitial];
    tipText.text = tip.text;
    venueName.text = venue.name;
    venueAddress.text = venue.venueAddress;
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


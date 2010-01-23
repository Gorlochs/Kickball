//
//  KBTextViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTextViewController.h"
#import "FoursquareAPI.h"
#import "KBMessage.h"

@implementation KBTextViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [textView becomeFirstResponder];
}

- (void) cancelView {
    [[Beacon shared] startSubBeaconWithName:@"Cancel Shout"];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) shout {
    if ([textView.text length] > 0) {
        [[FoursquareAPI sharedInstance] doCheckinAtVenueWithId:nil 
                                                      andShout:textView.text 
                                                       offGrid:NO
                                                     toTwitter:NO
                                                    withTarget:self 
                                                     andAction:@selector(shoutResponseReceived:withResponseString:)];
        [[Beacon shared] startSubBeaconWithName:@"Shout"];
    } else {
        NSLog(@"no text in shout field");
    }
}

- (void)shoutResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"instring: %@", inString);
	NSArray *shoutCheckins = [FoursquareAPI checkinsFromResponseXML:inString];
    NSLog(@"shoutCheckins: %@", shoutCheckins);
    
    // TODO: confirm that the shout was sent?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shoutSent"
                                                        object:nil
                                                      userInfo:nil];
    [self cancelView];
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
    [textView release];
    [super dealloc];
}


@end

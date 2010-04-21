    //
//  KBUserTweetsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBUserTweetsViewController.h"


@implementation KBUserTweetsViewController

@synthesize userDictionary;
@synthesize username;

- (void) showStatuses {
    [self startProgressBar:@"Retrieving your tweets..."];
    if (self.userDictionary) {
        [twitterEngine getUserTimelineFor:[self.userDictionary objectForKey:@"screen_name"] sinceID:0 startingAtPage:0 count:25];
    } else {
        [twitterEngine getUserTimelineFor:self.username sinceID:0 startingAtPage:0 count:25];
    }
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [userDictionary release];
    [username release];
    [screenNameLabel release];
    [fullName release];
    [location release];
    [super dealloc];
}


@end

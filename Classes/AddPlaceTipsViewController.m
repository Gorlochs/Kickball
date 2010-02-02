//
//  AddPlaceTipsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/12/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddPlaceTipsViewController.h"


@implementation AddPlaceTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    theTextView.font = [UIFont systemFontOfSize:14.0];
    [[Beacon shared] startSubBeaconWithName:@"Add Venue Advice View"];
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
    [theTextView release];
    [super dealloc];
}


@end

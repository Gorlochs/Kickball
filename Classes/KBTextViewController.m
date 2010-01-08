//
//  KBTextViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTextViewController.h"


@implementation KBTextViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [textView isFirstResponder];
}

- (void) cancelView {
//    [self.parentViewController.
    [self dismissModalViewControllerAnimated:YES];
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

//
//  ProgressViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/22/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "ProgressViewController.h"


@implementation ProgressViewController

@synthesize activityLabel;

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
    [self setupBusyAnimation];
    [stripedActivityIndicator startAnimating];
}

- (void)viewWillDisappear: (BOOL)animated
{
    [stripedActivityIndicator stopAnimating];
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
    [stripedActivityIndicator release];
    [activityLabel release];
    [super dealloc];
}

- (void) setupBusyAnimation {
    stripedActivityIndicator.animationImages = [NSArray arrayWithObjects:  
                                                [UIImage imageNamed:@"loading01.png"],
                                                [UIImage imageNamed:@"loading02.png"],
                                                [UIImage imageNamed:@"loading03.png"],
                                                [UIImage imageNamed:@"loading04.png"],
                                                [UIImage imageNamed:@"loading05.png"],
                                                [UIImage imageNamed:@"loading06.png"],
                                                [UIImage imageNamed:@"loading07.png"],
                                                [UIImage imageNamed:@"loading08.png"],
                                                [UIImage imageNamed:@"loading09.png"],
                                                [UIImage imageNamed:@"loading10.png"],
                                                [UIImage imageNamed:@"loading11.png"],
                                                [UIImage imageNamed:@"loading12.png"],
                                                [UIImage imageNamed:@"loading13.png"],
                                                [UIImage imageNamed:@"loading14.png"],
                                                [UIImage imageNamed:@"loading15.png"],
                                                [UIImage imageNamed:@"loading16.png"],
                                                [UIImage imageNamed:@"loading17.png"],
                                                nil];
    
    stripedActivityIndicator.animationDuration = 0.5;
    stripedActivityIndicator.animationRepeatCount = 0;
}

@end

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
    [super dealloc];
}

- (void) setupBusyAnimation {
    stripedActivityIndicator.animationImages = [NSArray arrayWithObjects:  
                                [UIImage imageNamed:@"blue-busy-01.png"],
                                [UIImage imageNamed:@"blue-busy-02.png"],
                                [UIImage imageNamed:@"blue-busy-03.png"],
                                [UIImage imageNamed:@"blue-busy-04.png"],
                                [UIImage imageNamed:@"blue-busy-05.png"],
                                [UIImage imageNamed:@"blue-busy-06.png"],
                                [UIImage imageNamed:@"blue-busy-07.png"],
                                nil];
    
    stripedActivityIndicator.animationDuration = 1.0;
    stripedActivityIndicator.animationRepeatCount = 0;
}

@end

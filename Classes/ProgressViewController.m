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
                                                [UIImage imageNamed:@"01.png"],
                                                [UIImage imageNamed:@"02.png"],
                                                [UIImage imageNamed:@"03.png"],
                                                [UIImage imageNamed:@"04.png"],
                                                [UIImage imageNamed:@"05.png"],
                                                [UIImage imageNamed:@"06.png"],
                                                [UIImage imageNamed:@"07.png"],
                                                [UIImage imageNamed:@"08.png"],
                                                [UIImage imageNamed:@"09.png"],
                                                [UIImage imageNamed:@"10.png"],
                                                [UIImage imageNamed:@"11.png"],
                                                [UIImage imageNamed:@"12.png"],
                                                [UIImage imageNamed:@"13.png"],
                                                [UIImage imageNamed:@"14.png"],
                                                [UIImage imageNamed:@"15.png"],
                                                [UIImage imageNamed:@"16.png"],
                                                [UIImage imageNamed:@"17.png"],
                                                nil];
    
    stripedActivityIndicator.animationDuration = 0.5;
    stripedActivityIndicator.animationRepeatCount = 0;
}

@end

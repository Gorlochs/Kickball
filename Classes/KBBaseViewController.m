//
//  KBBaseViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KBBaseViewController.h"


@implementation KBBaseViewController


- (void) backOneView {
    NSLog(@"backOneView is being called");
    //    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
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
    [super dealloc];
}


@end

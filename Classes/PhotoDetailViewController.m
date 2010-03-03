//
//  PhotoDetailViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "KBGoody.h"

@implementation PhotoDetailViewController

@synthesize goodyList;
@synthesize photoIndexToDisplay;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [photo loadImageFromURL:[NSURL URLWithString:((KBGoody*)[goodyList objectAtIndex:photoIndexToDisplay]).imagePath] withRoundedEdges:NO]; 
    
    [super viewDidLoad];
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
    [goodyList release];
    [super dealloc];
}


@end

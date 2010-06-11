    //
//  KBThumbnailViewController.m
//  Kickball
//
//  Created by Shawn B on 6/8/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBThumbnailViewController.h"
#import "KBPhotoViewController.h"


@implementation KBThumbnailViewController

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// FYI: this sucks moose balls
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
	[self setWantsFullScreenLayout:YES];
	[self.tableView setContentOffset:CGPointMake(0, -10)];
}

- (TTPhotoViewController*)createPhotoViewController { 
    return [[[KBPhotoViewController alloc] init] autorelease]; 
} 

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo { 
	KBPhotoViewController *theController = [[KBPhotoViewController alloc] initWithPhotoSource:self.photoSource]; 
	[theController setCenterPhoto:photo];
	[[self navigationController] pushViewController:theController animated:YES];
	[theController release]; 
	theController = nil; 
}

- (void)thumbsViewController:(TTThumbsViewController*)controller didSelectPhoto:(id<TTPhoto>)photo { 
    DLog("this doesn't get called");
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
    [super dealloc];
}

@end

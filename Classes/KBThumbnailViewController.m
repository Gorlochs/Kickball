    //
//  KBThumbnailViewController.m
//  Kickball
//
//  Created by Shawn B on 6/8/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBThumbnailViewController.h"


@implementation KBThumbnailViewController

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	UINavigationController* navController = self.navigationController;
	
	navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	[self setWantsFullScreenLayout:YES];
}

- (void)loadView {
    [super loadView];
    
//    _flagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flag_off.png"] 
//                                                   style:UIBarButtonItemStylePlain
//                                                  target:self 
//                                                  action:@selector(flagAction)];
//    
//    
//    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
//                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
//    
//    _toolbar.items = [NSArray arrayWithObjects:
//                      space, _previousButton, space, _flagButton, space, _nextButton, space, nil];
//    
//    
//    self.defaultImage = [UIImage imageNamed:@"imgLoader.png"];
//    
	self.navigationController.navigationBar.hidden = NO;
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

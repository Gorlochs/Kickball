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
	UINavigationController* navController = self.navigationController;
	
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	[self setWantsFullScreenLayout:YES];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
	self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (TTPhotoViewController*)createPhotoViewController { 
    return [[[KBPhotoViewController alloc] init] autorelease]; 
} 

- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo { 
    DLog(@"thumbsTableViewCell"); 
//} 
//
//- (void)thumbsViewController:(TTThumbsViewController*)controller 
//              didSelectPhoto:(id<TTPhoto>)photo 
//{ 
//    DLog(@"thumbsViewController"); 
    /* 
     [[[super _controller] delegate] thumbsViewController:[super 
     _controller] didSelectPhoto:photo]; 
     BOOL shouldNavigate = YES; 
     if ([[[super _controller] delegate] 
     respondsToSelector:@selector 
     (thumbsViewController:shouldNavigateToPhoto:)]) { 
     shouldNavigate = [[[super _controller] delegate] 
     thumbsViewController:[super _controller] 
     shouldNavigateToPhoto:photo]; 
     } 
     */ 
//    if (YES) { 
        KBPhotoViewController *theController = [[KBPhotoViewController alloc] initWithPhotoSource:self.photoSource]; 
        [theController setCenterPhoto:photo];
        [[self navigationController] pushViewController:theController animated:YES];
        [theController release]; 
        theController = nil; 
        /* 
         TTPhotoViewController* controller = [_controller 
         createPhotoViewController]; 
         controller.centerPhoto = photo; 
         [_controller.navigationController pushViewController:controller 
         animated:YES]; 
         */ 
//    } 
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

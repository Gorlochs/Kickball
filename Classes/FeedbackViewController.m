//
//  FeedbackViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FeedbackViewController.h"
#import "VersionInfoViewController.h"


@implementation FeedbackViewController

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    
    [super viewDidLoad];
}

- (void) nextOptionView {
    VersionInfoViewController *controller = [[VersionInfoViewController alloc] initWithNibName:@"VersionInfoViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

-(void)pressOptionsLeft{
	[[self navigationController] popViewControllerAnimated:YES];

}
-(void)pressOptionsRight{
	[self nextOptionView];
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

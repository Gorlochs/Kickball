//
//  FriendPriorityOptionViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendPriorityOptionViewController.h"
#import "AccountOptionsViewController.h"


@implementation FriendPriorityOptionViewController

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    
    [super viewDidLoad];
    
    [slider setMinimumTrackImage:nil forState:UIControlStateNormal];
    [slider setMaximumTrackImage:nil forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slideBar.png"] forState:UIControlStateNormal];
}

- (void) nextOptionView {
    AccountOptionsViewController *accountController = [[AccountOptionsViewController alloc] initWithNibName:@"AccountOptionsView_v2" bundle:nil];
    [self.navigationController pushViewController:accountController animated:YES];
    [accountController release];
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

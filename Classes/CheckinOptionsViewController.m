//
//  CheckinOptionsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "CheckinOptionsViewController.h"
#import "FriendPriorityOptionViewController.h"
#import "KBAccountManager.h"

@implementation CheckinOptionsViewController

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    
    [super viewDidLoad];
	[foursquareSwitch setOn:[[KBAccountManager sharedInstance] defaultPostToFoursquare]];
	[facebookSwitch setOn:[[KBAccountManager sharedInstance] defaultPostToFacebook]];
	[twitterSwitch setOn:[[KBAccountManager sharedInstance] defaultPostToTwitter]];
}

- (void) nextOptionView {
    FriendPriorityOptionViewController *controller = [[FriendPriorityOptionViewController alloc] initWithNibName:@"FriendPriorityOptionViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
-(void)pressOptionsLeft{
	[[self navigationController] popViewControllerAnimated:YES];

}
-(void)pressOptionsRight{
	[self nextOptionView];
}

- (IBAction) toggleFoursquare{
	[[KBAccountManager sharedInstance] setDefaultPostToFoursquare:[foursquareSwitch isOn]];
}
- (IBAction) toggleFacebook{
	[[KBAccountManager sharedInstance] setDefaultPostToFacebook:[facebookSwitch isOn]];
}
- (IBAction) toggleTwitter{
	[[KBAccountManager sharedInstance] setDefaultPostToTwitter:[twitterSwitch isOn]];
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

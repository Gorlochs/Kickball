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
}
-(void)pressOptionsLeft{
	NSArray *newStack = [NSArray arrayWithObjects:[(OptionsNavigationController*)self.navigationController base],[(OptionsNavigationController*)self.navigationController versionInfo],self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
	[[self navigationController] popViewControllerAnimated:YES];

}
-(void)pressOptionsRight{
	NSArray *newStack = [NSArray arrayWithObjects:[(OptionsNavigationController*)self.navigationController base],self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
	[[self navigationController] pushViewController:[(OptionsNavigationController*)self.navigationController account] animated:YES];
}



- (IBAction) toggleFoursquare{
	[[KBAccountManager sharedInstance] setDefaultPostToFoursquare:[foursquareSwitch isOn]];
}
- (IBAction) toggleFacebook{
	[[KBAccountManager sharedInstance] setDefaultPostToFacebook:[facebookSwitch isOn]];
	[[KBAccountManager sharedInstance] checkForCrossPollinateWarning:@"instaCheckin"];

}
- (IBAction) toggleTwitter{
	[[KBAccountManager sharedInstance] setDefaultPostToTwitter:[twitterSwitch isOn]];
	[[KBAccountManager sharedInstance] checkForCrossPollinateWarning:@"instaCheckin"];

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

//
//  FriendPriorityOptionViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendPriorityOptionViewController.h"
#import "AccountOptionsViewController.h"
#import "Utilities.h"

@implementation FriendPriorityOptionViewController

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    
    [super viewDidLoad];
    
    [slider setMinimumTrackImage:nil forState:UIControlStateNormal];
    [slider setMaximumTrackImage:nil forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"opt_sliderThumb.png"] forState:UIControlStateNormal];
	NSNumber *currentUserValue = [[Utilities sharedInstance] getCityRadius];
	int val = [currentUserValue intValue];
	if (val < 0) {
		[slider setValue:1.0 animated:NO];
	}else if (val >CITY_RADIUS_MEDIUM) {
		[slider setValue:0.75 animated:NO];
	}else if (val >CITY_RADIUS_SMALL) {
		[slider setValue:0.50 animated:NO];
	}else if (val >CITY_RADIUS_TINY) {
		[slider setValue:0.25 animated:NO];
	}else {
		[slider setValue:0.0 animated:NO];
	}
}

- (void) nextOptionView {
    AccountOptionsViewController *accountController = [[AccountOptionsViewController alloc] initWithNibName:@"AccountOptionsView_v2" bundle:nil];
    [self.navigationController pushViewController:accountController animated:YES];
    [accountController release];
}

- (IBAction) releasedSlider{
	float newValue =[slider	value];
	NSLog(@"new Slider value: %f",newValue);
	if (newValue>=0.875) { 
		[slider setValue:1.0 animated:YES]; // ∞
		[[Utilities sharedInstance] setCityRadius:CITY_RADIUS_INFINTE];
		[detailText setImage:[UIImage imageNamed:@"opt_x-desc.png"]];
	}else if (newValue>=0.625) { 
		[slider setValue:0.75 animated:YES]; // 100 miles
		[[Utilities sharedInstance] setCityRadius:CITY_RADIUS_LARGE];
		[detailText setImage:[UIImage imageNamed:@"100-desc.png"]];
	}else if (newValue>=0.375) { 
		[slider setValue:0.5 animated:YES]; // 50 miles
		[[Utilities sharedInstance] setCityRadius:CITY_RADIUS_MEDIUM];
		[detailText setImage:[UIImage imageNamed:@"50-desc.png"]];
	}else if (newValue>=0.125) {
		[slider setValue:0.25 animated:YES]; // 25 miles
		[[Utilities sharedInstance] setCityRadius:CITY_RADIUS_SMALL];
		[detailText setImage:[UIImage imageNamed:@"opt_25-desc.png"]];
	}else {
		[slider setValue:0.0 animated:YES]; //10 miles
		[[Utilities sharedInstance] setCityRadius:CITY_RADIUS_TINY];
		[detailText setImage:[UIImage imageNamed:@"opt_5-desc.png"]];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFriendsList" object:nil];

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

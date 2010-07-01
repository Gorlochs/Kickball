//
//  OptionsNavigationController.m
//  Kickball
//
//  Created by scott bates on 7/1/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "OptionsNavigationController.h"
#import "AccountOptionsViewController.h"
#import "CheckinOptionsViewController.h"
#import "FriendPriorityOptionViewController.h"
#import "VersionInfoViewController.h"
#import "FeedbackViewController.h"
#import "OptionsVC.h"

@implementation OptionsNavigationController
@synthesize base, account, checkin, friendPriority, versionInfo, feedback;

-(OptionsVC*)account{
	if (account==nil) {
		account = (OptionsVC*)[[AccountOptionsViewController alloc] initWithNibName:@"AccountOptionsView_v2" bundle:nil];
	}
	return account;
}

-(OptionsVC*)checkin{
	if (checkin==nil) {
		checkin = (OptionsVC*)[[CheckinOptionsViewController alloc] initWithNibName:@"CheckinOptionsViewController" bundle:nil];
	}
	return checkin;
}

-(OptionsVC*)friendPriority{
	if (friendPriority==nil) {
		friendPriority = (OptionsVC*)[[FriendPriorityOptionViewController alloc] initWithNibName:@"FriendPriorityOptionViewController" bundle:nil];
	}
	return friendPriority;
}
-(OptionsVC*)versionInfo{
	if (versionInfo==nil) {
		versionInfo = (OptionsVC*)[[VersionInfoViewController alloc] initWithNibName:@"VersionInfoViewController" bundle:nil];
	}
	return versionInfo;
}
-(OptionsVC*)feedback{
	if (feedback==nil) {
		feedback = (OptionsVC*)[[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
	}
	return feedback;
}

-(void)dealloc{
	[base release];
	[account release];
	[checkin release];
	[friendPriority release];
	[versionInfo release];
	[feedback release];
	[super dealloc];
}
@end

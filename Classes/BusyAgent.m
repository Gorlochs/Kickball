//
//  BusyAgent.m
//  Pagination
//
//  Created by Shaikh Sonny Aman on 1/12/10.
//  Copyright 2010 SHAIKH SONNY AMAN :) . All rights reserved.
//

#import "BusyAgent.h"

#define PROGRESS_ALPHA 0.85

static BusyAgent* agent;

@implementation BusyAgent
- (id)init{
	return nil;
}

- (id)myinit{
	if( (self = [super init])){
		progressViewController = [[ProgressViewController alloc] initWithNibName:@"ProgressView" bundle:nil];
		
		busyCount = 0;
		UIWindow* keywindow = [[UIApplication sharedApplication] keyWindow];
		view = [[UIView alloc] initWithFrame:[keywindow frame]];
		view.backgroundColor = [UIColor clearColor];
		view.userInteractionEnabled = NO;
		[view addSubview:progressViewController.view];
		
		[[[UIApplication sharedApplication] keyWindow] addSubview:view];
		[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:view];
		
//		wait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//		wait.hidesWhenStopped = NO;
//		//wait.frame = CGRectMake(147.5,227.5,25,25);
//		wait.center = view.center;
		
		// Label idea +code by rocotilos at iphonedevsdk.com(http://www.iphonedevsdk.com/forum/members/rocotilos.html)
//		busyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, 320, 21)];
//		busyLabel.textColor = [UIColor whiteColor];
//		busyLabel.backgroundColor = [UIColor clearColor];
//		busyLabel.shadowColor = [UIColor blackColor];
//		busyLabel.shadowOffset = CGSizeMake(-1,-1);
//		busyLabel.textAlignment = UITextAlignmentCenter;
//		busyLabel.text = @"Processing Request... Please Wait";
		
		[view addSubview:busyLabel];
		
		return self;
	}
	
	return nil;
}

- (void) makeBusy:(BOOL)yesOrno{
	if (yesOrno) {
		busyCount++;
	} else {
		busyCount--;
		if(busyCount<0){
			busyCount = 0;
		}
	}
	
	if (busyCount == 1){
		
		CGRect frame = progressViewController.view.frame;
		frame.origin.y = 70;
		progressViewController.view.frame = frame;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
		progressViewController.view.frame = CGRectMake(0, 
													   20, 
													   progressViewController.view.frame.size.width, 
													   progressViewController.view.frame.size.height);
		progressViewController.view.alpha = 1.0;
		
		[UIView commitAnimations];
	} else if(busyCount == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
		progressViewController.view.frame = CGRectMake(0, 
													   70, 
													   progressViewController.view.frame.size.width, 
													   progressViewController.view.frame.size.height);
		progressViewController.view.alpha = 0.0;
		[UIView commitAnimations];
	} else {
		[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:view];
	}

}

- (void) queueBusy{
	[self makeBusy:YES];
}
- (void) dequeueBusy{
	[self makeBusy:NO];
}


- (void) forceRemoveBusyState{
	busyCount = 0;
	[view removeFromSuperview];
}

+ (BusyAgent*)defaultAgent{
	if(!agent){
		agent =[[BusyAgent alloc] myinit];
	}
	return agent;
}

- (void)dealloc{
	[view release];
	[busyLabel release];
	[progressViewController release];
	
	[super dealloc];
}
@end

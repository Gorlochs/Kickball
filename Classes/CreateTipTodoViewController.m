//
//  CreateTipTodoViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/24/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "CreateTipTodoViewController.h"
#import "FoursquareAPI.h"

@implementation CreateTipTodoViewController

@synthesize venue;

- (void)viewDidLoad {
    [super viewDidLoad];
    tipTodoText.font = [UIFont systemFontOfSize:12.0];
    [tipTodoText becomeFirstResponder];
    venueName.text = venue.name;
    venueAddress.text = venue.addressWithCrossstreet;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [tipTodoText release];
    [tipTodoSwitch release];
    [tipId release];
    [venue release];
    [super dealloc];
}

#pragma mark 
#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 140) {
        textView.text = [textView.text substringToIndex:139];
    }
}

- (void)tipTodoResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	tipId = [FoursquareAPI tipIdFromResponseXML:inString];
    NSLog(@"tipid: %@", tipId);
    [self stopProgressBar];
    if (tipId != nil) {
        // present a thank you message
        [[NSNotificationCenter defaultCenter] postNotificationName:@"todoTipSent"
                                                            object:nil
                                                          userInfo:nil];
        [self dismissModalViewControllerAnimated:YES];
    } else {
        //sorry
    }
}

- (void) submitTipOrTodoToFoursquare {
    [tipTodoText resignFirstResponder];
    [self startProgressBar:@"Submitting Tip/Todo..."];
    NSString *tipOrTodo = nil;
    if (tipTodoSwitch.selectedSegmentIndex = 0) {
        NSLog(@"submitting tip");
        tipOrTodo = @"tip";
    } else {
        NSLog(@"submitting todo");
        tipOrTodo = @"todo";
    }
    [[FoursquareAPI sharedInstance] createTipTodoForVenue:venue.venueid type:tipOrTodo text:tipTodoText.text withTarget:self andAction:@selector(tipTodoResponseReceived:withResponseString:)];
    
}

- (void) callVenue {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", venue.phone]]];
}

- (void) cancel {
    [self dismissModalViewControllerAnimated];
}

@end

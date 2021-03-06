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
    self.hideHeader = YES;
    [super viewDidLoad];
    tipTodoText.font = [UIFont systemFontOfSize:12.0];
    [tipTodoText becomeFirstResponder];
//    venueName.text = venue.name;
//    venueAddress.text = venue.addressWithCrossstreet;
    [FlurryAPI logEvent:@"Create Tip or Todo"];
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
    [tipId release];
    [venue release];
    [characterCount release];
    [super dealloc];
}

#pragma mark 
#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 100) {
        textView.text = [textView.text substringToIndex:100];
    }
    characterCount.text = [NSString stringWithFormat:@"%d/100", [textView.text length]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self submitTipOrTodoToFoursquare];
        return NO;
    }
    return YES;
}

- (void)tipTodoResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"tip/todo response string: %@", inString);
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        tipId = [FoursquareAPI tipIdFromResponseXML:inString];
        DLog(@"tipid: %@", tipId);
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
    [self stopProgressBar];
}

- (void) submitTipOrTodoToFoursquare {
    [tipTodoText resignFirstResponder];
    if ([tipTodoText.text length] == 0) {
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Submission Failed" andMessage:@"Enter some text and give it another try."];
        [self displayPopupMessage:message];
        [message release];
    } else {
        [self startProgressBar:@"Submitting Tip/Todo..."];
        NSString *tipOrTodo = nil;
//        if (tipTodoSwitch.selectedSegmentIndex == 0) {
            [FlurryAPI logEvent:@"Creating Tip"];
            DLog(@"submitting tip");
            tipOrTodo = @"tip";
//        } else {
//            [FlurryAPI logEvent:@"Creating Todo"];
//            DLog(@"submitting todo");
//            tipOrTodo = @"todo";
//        }
        [[FoursquareAPI sharedInstance] createTipTodoForVenue:venue.venueid type:tipOrTodo text:tipTodoText.text withTarget:self andAction:@selector(tipTodoResponseReceived:withResponseString:)];
    }
}

- (void) callVenue {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", venue.phone]]];
}

- (void) cancel {
    [self dismissModalViewControllerAnimated:YES];
}

@end

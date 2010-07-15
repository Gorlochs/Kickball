//
//  FeedbackViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FeedbackViewController.h"
#import "VersionInfoViewController.h"
#import "ASIFormDataRequest.h"
#import "UIAlertView+Helper.h"


@implementation FeedbackViewController

- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    self.hideHeader = YES;
    subjects = [[NSMutableArray alloc] initWithCapacity:6];
	[subjects addObject:@"Comments and/or happy thoughts"];
	[subjects addObject:@"Bugs or issues"];
	[subjects addObject:@"Wish Kickball had..."];
	[subjects addObject:@"Foursquare"];
	[subjects addObject:@"Twitter"];
	[subjects addObject:@"Facebook"];
	[subjectLabel setText:[subjects objectAtIndex:0]];
    [super viewDidLoad];
	[subjectPicker reloadAllComponents];
	[self showPicker];
}

- (IBAction) showPicker{
	[content resignFirstResponder];
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [subjectPicker setCenter:CGPointMake(160, 338)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}
- (void) hidePicker{
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [subjectPicker setCenter:CGPointMake(160, 560)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark picker view data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if (subjects!=nil) {
		return [subjects count];
	}
	return 0;
}

#pragma mark -
#pragma mark picker view delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    
    // note: custom picker doesn't care about titles, it uses custom views
    if (pickerView == subjectPicker)
    {
        if (component == 0)
        {
            returnStr = [subjects objectAtIndex:row];
        }
	}
    
    return returnStr;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [subjectLabel setText:[subjects objectAtIndex:row]];
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth = 0.0;
	
    if (component == 0)
        componentWidth = 280.0; // first column size is wider to hold names
    else
        componentWidth = 40.0;  // second column is narrower to show numbers
	
    return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

#pragma mark -
#pragma mark  UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	[self hidePicker];
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        //[self submitTweet];
		[content resignFirstResponder];
		[self sendFeedback];
		return NO;
    }
    return YES;
}

		 
-(void)sendFeedback{
	if ([content.text length]<2) {
		UIAlertViewQuick(@"Error", @"Please provide some feedback", @"OK");

		return;
	}
	[self startProgressBar:@"Submitting..."];

	//http://gorlochs.com/kickball/app/feedback/send.php
    ASIFormDataRequest *feedback = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://gorlochs.com/kickball/app/feedback/send.php"]] autorelease];
    [feedback setRequestMethod:@"POST"];
    [feedback setPostValue:subjectLabel.text forKey:@"subject"];
    [feedback setPostValue:content.text forKey:@"feedback"];
	[feedback setDidFailSelector:@selector(feedbackWentWrong:)];
    [feedback setDidFinishSelector:@selector(feedbackDidFinish:)];
    [feedback setTimeOutSeconds:100];
    [feedback setDelegate:self];
    [feedback startAsynchronous];	
}

- (void) feedbackWentWrong:(ASIHTTPRequest *) request {
	[self stopProgressBar];
    [self displayFoursquareErrorMessage:@"Unable to send you feedback."];
    DLog(@"BOOOOOOOOOOOO!");
    DLog(@"response msg: %@", request.responseStatusMessage);
}

- (void) feedbackDidFinish:(ASIHTTPRequest *) request {
	[self stopProgressBar];
	KBMessage *message = [[KBMessage alloc] initWithMember:@"Thanks!" andMessage:@"Feedback submitted!"];
    [self displayPopupMessage:message];
    [message release];
    DLog(@"YAAAAAAAAAAAY!");
    DLog(@"response msg: %@", request.responseStatusMessage);
}


- (void) nextOptionView {
	[content resignFirstResponder];
	[self hidePicker];
    VersionInfoViewController *controller = [[VersionInfoViewController alloc] initWithNibName:@"VersionInfoViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


-(void)pressOptionsLeft{
	[content resignFirstResponder];
	[self hidePicker];
	NSArray *newStack = [NSArray arrayWithObjects:[(OptionsNavigationController*)self.navigationController base],[(OptionsNavigationController*)self.navigationController friendPriority],self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
	[[self navigationController] popViewControllerAnimated:YES];
}
-(void)pressOptionsRight{
	[content resignFirstResponder];
	[self hidePicker];
	NSArray *newStack = [NSArray arrayWithObjects:[(OptionsNavigationController*)self.navigationController base],self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
	[[self navigationController] pushViewController:[(OptionsNavigationController*)self.navigationController versionInfo] animated:YES];
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
	[subjects release];
    [super dealloc];
}


@end

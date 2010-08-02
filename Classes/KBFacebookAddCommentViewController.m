    //
//  KBFacebookAddCommentViewController.m
//  Kickball
//
//  Created by scott bates on 6/18/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookAddCommentViewController.h"
#import "FoursquareAPI.h"
#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "GraphObject.h"
#import "KBFacebookViewController.h"


@implementation KBFacebookAddCommentViewController
@synthesize fbId, parentView, isComment;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.hideHeader = YES;
    [super viewDidLoad];
    tipTodoText.font = [UIFont systemFontOfSize:12.0];
    [tipTodoText becomeFirstResponder];
    [FlurryAPI logEvent:@"Facebook Add Comment"];
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 400) {
        textView.text = [textView.text substringToIndex:400];
    }
    characterCount.text = [NSString stringWithFormat:@"%d/400", [textView.text length]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
		if ([tipTodoText.text length] == 0) {
			KBMessage *message = [[KBMessage alloc] initWithMember:@"Submission Failed" andMessage:@"Please enter in some text and try again."];
			[self displayPopupMessage:message];
			[message release];
		} else {
			[self startProgressBar:@"Submitting comment..."];
			[FlurryAPI logEvent:@"Facebook posting comment"];
			DLog(@"submitting comment");
			[NSThread detachNewThreadSelector:@selector(postFacebookComment) toTarget:self withObject:nil];
		}
        return NO;
    }
    return YES;
}

-(void)postFacebookComment{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	if (isComment) {
		/*GraphObject *result = */[graph putCommentToObject:fbId message:tipTodoText.text];
	}else {
		/*GraphObject *result = */[graph putWallPost:fbId message:tipTodoText.text attachment:nil];
	}
	[graph release];

	[pool release];
	[self performSelectorOnMainThread:@selector(success) withObject:nil waitUntilDone:NO];
}


- (void)success {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
    KBMessage *msg = [[KBMessage alloc] initWithMember:@"Kickball Notification" andMessage:@"Your comment was posted"];
    [parentView displayPopupMessage:msg];
	[parentView refreshTable];
    [msg release];
	[self stopProgressBar];
}



- (void) cancel {
    [self dismissModalViewControllerAnimated:YES];
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
	[fbId release];
	[parentView release];
	//[tipTodoText release];
    //[tipId release];
    //[characterCount release];
    [super dealloc];
}


@end

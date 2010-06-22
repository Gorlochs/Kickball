//
//  FBFacebookCreatePostViewController.m
//  Kickball
//
//  Created by scott bates on 6/21/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "FBFacebookCreatePostViewController.h"


@implementation FBFacebookCreatePostViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	hideHeader = NO;
	pageViewType = KBPageViewTypeOther;
	pageType = KBPageTypeOther;
    [super viewDidLoad];
	
	[tweetTextView becomeFirstResponder];
    tweetTextView.font = [UIFont fontWithName:@"Helvetica" size:13.0];
	characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [tweetTextView.text length]];
	photoManager = [KBPhotoManager sharedInstance];
    photoManager.delegate = self;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

//
//  KBCreateTweetViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBCreateTweetViewController.h"


@implementation KBCreateTweetViewController

@synthesize replyToStatusId;
@synthesize replyToScreenName;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.replyToScreenName) {
        tweetTextView.text = [NSString stringWithFormat:@"@%@ ", self.replyToScreenName];
    }
    [tweetTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark 
#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 140) {
        textView.text = [textView.text substringToIndex:139];
    }
    characterCountLabel.text = [NSString stringWithFormat:@"%d/140", [textView.text length]];
}

#pragma mark 
#pragma mark memory management methods

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [tweetTextView release];
    [characterCountLabel release];
    [sendTweet release];
    [cancel release];
    [geoTag release];
    [attachPhoto release];
    
    [replyToStatusId release];
    [replyToScreenName release];
    [super dealloc];
}


@end

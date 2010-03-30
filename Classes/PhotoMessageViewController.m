//
//  PhotoMessageViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/29/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PhotoMessageViewController.h"
#import "PlaceDetailViewController.h"

@implementation PhotoMessageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [photoMessage becomeFirstResponder];
}

- (void) addMessageToPhoto {
    NSDictionary *messageInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:photoMessage.text, nil] forKeys:[NSArray arrayWithObjects:@"message", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"attachMessageToPhoto"
                                                        object:nil
                                                      userInfo:messageInfo];	
}

- (void) noMessageThanks {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"attachMessageToPhoto"
                                                        object:nil
                                                      userInfo:nil];	
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] > 50) {
        textView.text = [textView.text substringToIndex:50];
    }
    numCharacters.text = [NSString stringWithFormat:@"%02d", [textView.text length]];
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
    [photoMessage release];
    [super dealloc];
}


@end

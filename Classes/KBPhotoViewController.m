//
//  KBPhotoViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBPhotoViewController.h"
#import "MockPhotoSource.h"
#import "ASIHTTPRequest.h"
#import "KBGoody.h"
#import "KBMessage.h"



@implementation KBPhotoViewController

@synthesize startIndex;
@synthesize goodies;

- (void)loadView {
    [super loadView];
    
    _flagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flag_off.png"] 
                                                   style:UIBarButtonItemStylePlain
                                                  target:self 
                                                  action:@selector(flagAction)];
    
    
    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    _toolbar.items = [NSArray arrayWithObjects:
                      space, _previousButton, space, _flagButton, space, _nextButton, space, nil];
    
    
    self.defaultImage = [UIImage imageNamed:@"imgLoader.png"];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)flagAction {
    NSLog(@"photo index: %d", _centerPhotoIndex);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Would you like to flag this photo as inappropriate?" 
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = _centerPhotoIndex;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"INAPPROPRIATE!!!!");
        NSString *gorlochUrlString = [NSString stringWithFormat:@"http://kickball.gorlochs.com/kickball/gifts/inappropriate/%@.xml", 
                                      ((KBGoody*)[goodies objectAtIndex:actionSheet.tag]).goodyId];
        NSLog(@"url: %@", gorlochUrlString);
        ASIHTTPRequest *gorlochRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:gorlochUrlString]] autorelease];
        
        [gorlochRequest setRequestMethod:@"PUT"];
        [gorlochRequest setDidFailSelector:@selector(flagWentWrong:)];
        [gorlochRequest setDidFinishSelector:@selector(flagDidFinish:)];
        [gorlochRequest setTimeOutSeconds:100];
        [gorlochRequest setDelegate:self];
        [gorlochRequest startAsynchronous];
    }
}

- (void) flagWentWrong:(ASIHTTPRequest *) request {
    NSLog(@"flagging went wrong: %@", [request responseString]);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"There was an error with the flagging of this photo.  Please try again later."];
    [self displayPopupMessage:message];
    [message release];
}

- (void) flagDidFinish:(ASIHTTPRequest *) request {
    NSLog(@"flagged inappropriate: %@", [request responseString]);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"We have flagged this photo and will review it shortly. Thanks for making the world a safer place."];
    [self displayPopupMessage:message];
    [message release];
}

// copy and paste from KBBaseViewController
- (void) displayPopupMessage:(KBMessage*)message {
    
    popupView = [[PopupMessageView alloc] initWithNibName:@"PopupMessageView" bundle:nil];
    popupView.message = message;
    popupView.view.alpha = 0;
    //    popupView.view.layer.cornerRadius = 8.0;
    [self.view addSubview:popupView.view];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    popupView.view.alpha = 1.0;
    
    [UIView commitAnimations];
}

@end

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
#import "KBDialogueManager.h"


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
    
	self.navigationController.navigationBar.hidden = NO;
}

//- (void)showThumbnails {
//    if (!_thumbsController) {
//        // The photo source had no URL mapping in TTURLMap, so we let the subclass show the thumbs
//        _thumbsController = [[self createThumbsViewController] retain];
//        _thumbsController.photoSource = _photoSource;
//    }
//    
//    [self.navigationController pushViewController:_thumbsController animatedWithTransition:UIViewAnimationTransitionNone];
//}

- (void)flagAction {
    DLog(@"photo index: %d", _centerPhotoIndex);
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
        DLog(@"INAPPROPRIATE!!!!");
        NSString *gorlochUrlString = [NSString stringWithFormat:@"%@/gifts/inappropriate/%@.xml",
                                      kickballDomain,
                                      ((KBGoody*)[goodies objectAtIndex:actionSheet.tag]).goodyId];
        DLog(@"url: %@", gorlochUrlString);
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
    DLog(@"flagging went wrong: %@", [request responseString]);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"Oops! There was an error in flagging this photo. Give it another try."];
    [self displayPopupMessage:message];
    [message release];
}

- (void) flagDidFinish:(ASIHTTPRequest *) request {
    DLog(@"flagged inappropriate: %@", [request responseString]);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Kickball Message" andMessage:@"This photo has been flagged for review. Thanks for making the world a safer place."];
    [self displayPopupMessage:message];
    [message release];
}

// copy and paste from KBBaseViewController
- (void) displayPopupMessage:(KBMessage*)message {
    
	[[KBDialogueManager sharedInstance] displayMessage:message];
	/*
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
	 */
}

- (void) dealloc {
    [_flagButton release];
    [goodies release];
    [popupView release];
    [super dealloc];
}

@end

//
//  KBFacebookLoginViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/22/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBFacebookLoginViewController.h"


@implementation KBFacebookLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad {
    
    self.hideHeader = YES;
    self.hideRefresh = YES;
    
    [super viewDidLoad];
    FBLoginButton* button = [[[FBLoginButton alloc] init] autorelease];
    button.style = FBLoginButtonStyleWide;
    
    CGRect frame = button.frame;
    frame.origin = CGPointMake([self view].frame.size.width/2 - button.frame.size.width/2, 
                               [self view].frame.size.height/2 - button.frame.size.height/2 - 20);
    
    button.frame = frame;
    
//    CGRectMake([self view].frame.size.width/2 - button.frame.size.width/2, 
//                              [self view].frame.size.height/2 - button.frame.size.height/2 - 20,
//                              button.frame.size.width, 
//                              button.frame.size.height);
    button.enabled = YES;
    [self.view addSubview:button];
}

#pragma mark -
#pragma mark FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
    
}

- (void)sessionDidNotLogin:(FBSession*)session {
    
}

- (void)sessionDidLogout:(FBSession*)session {
    
}

#pragma mark -
#pragma mark FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result {
    
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
    
}

#pragma mark -
#pragma mark memory management

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
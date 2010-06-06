    //
//  AbstractFacebookViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/6/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "AbstractFacebookViewController.h"
#import "KBAccountManager.h"

static NSString* kApiKey = @"4585c2e42804bca19e21eb30d402905e";
static NSString* kApiSecret = @"5cd7d10f85a36d5aeb4f2f7f99e1c85b"; // @"<YOUR SECRET KEY>";
static NSString* kGetSessionProxy = nil; // @"<YOUR SESSION CALLBACK)>";


@implementation AbstractFacebookViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad {
    if (kGetSessionProxy) {
        _session = [[FBSession sessionForApplication:kApiKey getSessionProxy:kGetSessionProxy delegate:self] retain];
    } else {
        _session = [[FBSession sessionForApplication:kApiKey secret:kApiSecret delegate:self] retain];
    }
    DLog(@"FB session: %@", _session);
    //headerNibName = HEADER_NIB_FOURSQUARE;
    [super viewDidLoad];
    
    if (!self.hideHeader) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:HEADER_NIB_FOURSQUARE owner:self options:nil];
        FoursquareHeaderView *headerView = [nibViews objectAtIndex:0];
        [self.view addSubview:headerView];
    }
    
    [_session resume];
    
    // this is a hack. the abstract facebook vc has to inherit from the 4sq vc, which f's everything up
    // this is being called again after all the [super viewDidLoad] calls to straighten the tabs out
    footerType = KBFooterTypeFacebook;
    [self setTabImages];
}

#pragma mark -
#pragma mark FBSessionDelegate

- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	// user just successfully logged in
	// this also gets called when the app starts up
    DLog(@"User with id %lld logged in.", uid);
	[[KBAccountManager sharedInstance] setUsesFacebook:YES];
	[self hideAppropriateTabs];
}

- (void)sessionDidNotLogin:(FBSession*)session {

}

- (void)sessionDidLogout:(FBSession*)session {
	// user just logged out
    [[KBAccountManager sharedInstance] setUsesFacebook:NO];
	[self hideAppropriateTabs];
}

#pragma mark -
#pragma mark FBRequestDelegate

- (void)request:(FBRequest*)request didLoad:(id)result {

}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {

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
    [_session release];
    [super dealloc];
}


@end

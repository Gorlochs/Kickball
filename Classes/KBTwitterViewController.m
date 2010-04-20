    //
//  KBTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterViewController.h"
#import "KBTwitterManager.h"
#import "KBTweetListViewController.h"
#import "KBMentionsViewController.h"
#import "KBDirectMentionsViewController.h"


@implementation KBTwitterViewController

@synthesize twitterEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


- (void) showUserTimeline {
    KBTweetListViewController *controller = [[KBTweetListViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.view addSubview:controller.view];
}

- (void) showMentions {
    KBMentionsViewController *controller = [[KBMentionsViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.view addSubview:controller.view];
}

- (void) showDirectMessages {
    KBDirectMentionsViewController *controller = [[KBDirectMentionsViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.view addSubview:controller.view];
}

- (void) showSearch {
    
}

- (void)viewDidLoad {
    twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
    NSLog(@"twitterengine: %@", twitterEngine);
    
    headerNibName = HEADER_NIB_TWITTER;
    footerType = KBFooterTypeTwitter;
    
    [super viewDidLoad];
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
    [super dealloc];
}


@end

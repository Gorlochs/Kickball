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
#import "KBDirectMessagesViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBTwitterSearchViewController.h"
#import "KBGeoTweetMapViewController.h"


@implementation KBTwitterViewController

@synthesize twitterEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    twitterEngine = [[KBTwitterManager twitterManager] twitterEngine];
    NSLog(@"twitterengine: %@", twitterEngine);
    
    headerNibName = HEADER_NIB_TWITTER;
    footerType = KBFooterTypeTwitter;
    
    [super viewDidLoad];
    
    if (pageViewType == KBPageViewTypeList) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"twitMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"twitMap02.png"] forState:UIControlStateHighlighted];
        centerHeaderButton.enabled = YES;
    } else if (pageViewType == KBPageViewTypeMap) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"twitList01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"twitList02.png"] forState:UIControlStateHighlighted];
        centerHeaderButton.enabled = YES;
    } else if (pageViewType == KBPageViewTypeOther) {
        [centerHeaderButton setImage:[UIImage imageNamed:@"twitMap01.png"] forState:UIControlStateNormal];
        [centerHeaderButton setImage:[UIImage imageNamed:@"twitMap02.png"] forState:UIControlStateHighlighted];
        centerHeaderButton.enabled = NO;
    }
}

// FIXME: all these need to be fixed. we should be using navcontroller
- (void) flipBetweenMapAndList {
    KBGeoTweetMapViewController *controller = [[KBGeoTweetMapViewController alloc] initWithNibName:@"KBGeoTweetMapViewController" bundle:nil];
    [self.view addSubview:controller.view];
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
    KBDirectMessagesViewController *controller = [[KBDirectMessagesViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.view addSubview:controller.view];
}

- (void) showSearch {
    KBTwitterSearchViewController *controller = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTwitterSearchViewController" bundle:nil];
    [self.view addSubview:controller.view];
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

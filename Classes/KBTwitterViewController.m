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
#import "KBCreateTweetViewController.h"


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
    
    //headerNibName = HEADER_NIB_TWITTER;
    footerType = KBFooterTypeTwitter;
    
    [super viewDidLoad];
    
    if (!self.hideHeader) {
        NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:HEADER_NIB_TWITTER owner:self options:nil];
        FoursquareHeaderView *headerView = [nibViews objectAtIndex:0];
        [self.view addSubview:headerView];
    }
    
    if (pageType == KBPageTypeOther) {
        //friendButton.enabled = NO;
        homeBackView.frame = CGRectMake(0, 0, homeBackView.frame.size.width, homeBackView.frame.size.height);
        [self.view insertSubview:homeBackView belowSubview:centerHeaderButton];
        //[placesButton setImage:[UIImage imageNamed:@"placesTab01.png"] forState:UIControlStateNormal];
    }
    
    if (pageViewType == KBPageViewTypeList) {
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap01.png"] forState:UIControlStateNormal];
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap02.png"] forState:UIControlStateHighlighted];
        twitterCenterHeaderButton.enabled = YES;
    } else if (pageViewType == KBPageViewTypeMap) {
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitList01.png"] forState:UIControlStateNormal];
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitList02.png"] forState:UIControlStateHighlighted];
        twitterCenterHeaderButton.enabled = YES;
    } else if (pageViewType == KBPageViewTypeOther) {
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap01.png"] forState:UIControlStateNormal];
        [twitterCenterHeaderButton setImage:[UIImage imageNamed:@"twitMap02.png"] forState:UIControlStateHighlighted];
        twitterCenterHeaderButton.enabled = NO;
    }
    footerType = KBFooterTypeTwitter;
    [self setTabImages];
}

- (void) openTweetModalView {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
    [self presentModalViewController:tweetController animated:YES];
    [tweetController release];
}

- (void) flipBetweenMapAndList {
    if (pageViewType == KBPageViewTypeList) {
        KBGeoTweetMapViewController *controller = [[KBGeoTweetMapViewController alloc] initWithNibName:@"KBGeoTweetMapViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:NO];
        [controller release];
    } else {
        [self backOneViewNotAnimated];
    }
}

- (void) showUserTimeline {
    KBTweetListViewController *controller = [[KBTweetListViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (void) showMentions {
    KBMentionsViewController *controller = [[KBMentionsViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (void) showDirectMessages {
    KBDirectMessagesViewController *controller = [[KBDirectMessagesViewController alloc] initWithNibName:@"KBTweetListViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (void) showSearch {
    KBTwitterSearchViewController *controller = [[KBTwitterSearchViewController alloc] initWithNibName:@"KBTwitterSearchViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
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

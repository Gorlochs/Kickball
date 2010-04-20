    //
//  KBDirectMentionsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBDirectMentionsViewController.h"


@implementation KBDirectMentionsViewController

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesRetrieved:) name:kTwitterDMRetrievedNotificationKey object:nil];
    [super viewDidLoad];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM01.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    [twitterEngine getDirectMessagesSinceID:0 startingAtPage:0];
}

- (void)messagesRetrieved:(NSNotification *)inNotification {
    if (inNotification) {
        if ([inNotification userInfo]) {
            NSDictionary *userInfo = [inNotification userInfo];
            if ([userInfo objectForKey:@"statuses"]) {
                statuses = [[userInfo objectForKey:@"statuses"] retain];
                tweets = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
                for (NSDictionary *dict in statuses) {
                    [tweets addObject:[[KBTweet alloc] initWithDictionary:dict]];
                }
                [theTableView reloadData];
            }
        }
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kTwitterDMRetrievedNotificationKey];
}


- (void)dealloc {
    [super dealloc];
}


@end

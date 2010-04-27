//
//  KBGeoTweetMapViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/27/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBGeoTweetMapViewController.h"
#import "KBLocationManager.h"

#define GEO_TWITTER_RADIUS 1


@implementation KBGeoTweetMapViewController

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeMap;
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchRetrieved:) name:kTwitterSearchRetrievedNotificationKey object:nil];
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets01.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    [self startProgressBar:@"Retrieving your tweets..."];
    [self executeQuery:0];
}

- (void)searchRetrieved:(NSNotification *)inNotification {
    NSLog(@"inside searchRetrieved: %@", inNotification);
//    if (inNotification) {
//        if ([inNotification userInfo]) {
//            NSDictionary *userInfo = [inNotification userInfo];
//            if ([userInfo objectForKey:@"searchResults"]) {
//                statuses = [[userInfo objectForKey:@"searchResults"] retain];
//                tweets = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
//                //int i = 0;
//                for (NSDictionary *dict in statuses) {
//                    //if (i++ < [statuses count]) {
//                    [tweets addObject:[[KBSearchResult alloc] initWithDictionary:dict]];
//                    //}
//                }
//                // FIXME: remove last dictionary object
//                [theTableView reloadData];
//            }
//        }
//    }
//    [self stopProgressBar];
//    [self dataSourceDidFinishLoadingNewData];
}

- (void) executeQuery:(int)pageNumber {
    [twitterEngine getSearchResultsForQuery:nil
                                    sinceID:0 
                             startingAtPage:pageNumber
                                      count:25 
                                    geocode:[NSString stringWithFormat:@"%@,%@,%dmi", 
                                             [NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] latitude]],
                                             [NSString stringWithFormat:@"%f",[[KBLocationManager locationManager] longitude]],
                                             GEO_TWITTER_RADIUS
                                             ]
     ];
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

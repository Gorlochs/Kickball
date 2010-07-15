//
//  ProfileTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "ProfileTwitterViewController.h"
#import "KBTwitterCell.h"

#define TWITTER_DATE_FORMAT @"ccc MMM dd HH:mm:ss Z yyyy"

@implementation ProfileTwitterViewController

@synthesize tweets;

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"warning, if you are seeing this message and the view has links, notifications must be cleaned up!");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    [FlurryAPI logEvent:@"Profile Twitter View"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:1];
    //memleak orderedTweets = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSDictionary *tweet in tweets) {
        [arr addObject:[tweet objectForKey:@"id"]];
    }
    orderedTweets = [[NSMutableDictionary alloc] initWithObjects:tweets forKeys:arr];
    [arr release];
    NSArray *tempArray = [[NSArray alloc] initWithArray:[orderedTweets allKeys]];
    sortedKeys = [[NSArray alloc] initWithArray:[tempArray sortedArrayUsingSelector:@selector(compare:)]];
    [tempArray release];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tweets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    KBTwitterCell *cell = (KBTwitterCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTwitterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [locale release];
    [dateFormatter setDateFormat:TWITTER_DATE_FORMAT];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // reverse sort!
    NSDictionary *tweet = [orderedTweets objectForKey:[sortedKeys objectAtIndex:[sortedKeys count] - indexPath.row - 1]];
    
    //NSDate *date = [dateFormatter dateFromString:[dict objectForKey:@"created_at"]];
    //[dateFormatter setDateFormat:@"MM-dd-YYYY"];
    
	//[tweetLabel setText:[NSString stringWithFormat:@"%@  (%@)", [tweet objectForKey:@"text"], [dateFormatter stringFromDate:[tweet objectForKey:@"created_at"]]]];
    [cell.tweetLabel setText:[tweet objectForKey:@"text"]];
    [cell.tweetLabel setLinksEnabled:YES];
	
    [dateFormatter release];
	
    return cell;
}

- (void)handleTweetNotification:(NSNotification *)notification {
    [self openWebView:[notification object]];
	//DLog(@"handleTweetNotification: notification = %@", notification);
}

- (void)dealloc {
    //[tweets release];
    if (orderedTweets) [orderedTweets release];
    if (sortedKeys) [sortedKeys release];
    [super dealloc];
}


@end


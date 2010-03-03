//
//  ProfileTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "ProfileTwitterViewController.h"
#import "IFTweetLabel.h"

#define TWITTER_DATE_FORMAT @"ccc MMM dd HH:mm:ss Z yyyy"

@implementation ProfileTwitterViewController

@synthesize tweets;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    [[Beacon shared] startSubBeaconWithName:@"Profile Twitter View"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:1];
    orderedTweets = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSDictionary *tweet in tweets) {
        [arr addObject:[tweet objectForKey:@"id"]];
    }
    orderedTweets = [[NSMutableDictionary alloc] initWithObjects:tweets forKeys:arr];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    IFTweetLabel *tweetLabel = [[[IFTweetLabel alloc] initWithFrame:CGRectMake(10.0f, 3.0f, 300.0f, 60.0f)] autorelease];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        [cell addSubview:tweetLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TWITTER_DATE_FORMAT];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // reverse sort!
    NSDictionary *tweet = [orderedTweets objectForKey:[sortedKeys objectAtIndex:[sortedKeys count] - indexPath.row - 1]];
    
    //NSDate *date = [dateFormatter dateFromString:[dict objectForKey:@"created_at"]];
    [dateFormatter setDateFormat:@"MM-dd-YYYY"];
    
	[tweetLabel setFont:[UIFont systemFontOfSize:12.0f]];
	[tweetLabel setTextColor:[UIColor blackColor]];
	[tweetLabel setBackgroundColor:[UIColor clearColor]];
	[tweetLabel setNumberOfLines:0];
	//[tweetLabel setText:[NSString stringWithFormat:@"%@  (%@)", [tweet objectForKey:@"text"], [dateFormatter stringFromDate:[tweet objectForKey:@"created_at"]]]];
    [tweetLabel setText:[tweet objectForKey:@"text"]];
	[tweetLabel setLinksEnabled:YES];
	
    //[tweetLabel release];
    
    // Set up the cell...
//    cell.textLabel.numberOfLines = 3;
//    NSDictionary *dict = (NSDictionary*)[tweets objectAtIndex:indexPath.row];
//    //    NSLog(@"date: %@", [dict objectForKey:@"created_at"]);
//    //    NSDate *tweetDate = [dateFormatter dateFromString:[dict objectForKey:@"created_at"]];
//    //    [dateFormatter setDateFormat:@"MM-dd-YYYY HH:mm:ss"];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict objectForKey:@"text"], [dict objectForKey:@"created_at"]];
    [dateFormatter release];
	
    return cell;
}

- (void)handleTweetNotification:(NSNotification *)notification {
    [self openWebView:[notification object]];
	NSLog(@"handleTweetNotification: notification = %@", notification);
}

- (void)dealloc {
    [theTableView release];
    [tweets release];
    [orderedTweets release];
    [sortedKeys release];
    [super dealloc];
}


@end


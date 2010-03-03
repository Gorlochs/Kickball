//
//  PlaceTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "PlaceTwitterViewController.h"
#import "MGTwitterEngine.h"
#import "IFTweetLabel.h"
#import "Beacon.h"

@implementation PlaceTwitterViewController

@synthesize twitterName, venueName;


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    // TODO: figure out why this isn't working (i.e., the navigation bar isn't being displayed)
    venueLabel.text = venueName;

    MGTwitterEngine *twitterEngine = [[[MGTwitterEngine alloc] initWithDelegate:self] autorelease];
    NSString *timeline = [twitterEngine getUserTimelineFor:twitterName sinceID:0 startingAtPage:0 count:20];
    NSLog(@"timeline: %@", timeline);
    [[Beacon shared] startSubBeaconWithName:@"Venue Twitter Feed"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    twitterStatuses = nil;
    twitterName = nil;
    venueName = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    twitterStatuses = nil;
    twitterName = nil;
    venueName = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sortedKeys count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    IFTweetLabel *tweetLabel = [[[IFTweetLabel alloc] initWithFrame:CGRectMake(10.0f, 3.0f, 300.0f, 60.0f)] autorelease]; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:tweetLabel];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-YYYY"];
    
    // reverse sort!
    NSDictionary *tweet = [orderedTweets objectForKey:[sortedKeys objectAtIndex:[sortedKeys count] - indexPath.row - 1]];
    
    [tweetLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [tweetLabel setTextColor:[UIColor blackColor]];
    [tweetLabel setBackgroundColor:[UIColor clearColor]];
    [tweetLabel setNumberOfLines:0];
    //	[tweetLabel setText:[NSString stringWithFormat:@"%@  (%@)", [tweet objectForKey:@"text"], [dateFormatter stringFromDate:[tweet objectForKey:@"created_at"]]]];
    [tweetLabel setText:[tweet objectForKey:@"text"]];
    [tweetLabel setLinksEnabled:YES];
    [dateFormatter release];   

    
    // Set up the cell...
//    cell.textLabel.numberOfLines = 3;
//    NSDictionary *dict = (NSDictionary*)[twitterStatuses objectAtIndex:indexPath.row];
////    NSLog(@"date: %@", [dict objectForKey:@"created_at"]);
////    NSDate *tweetDate = [dateFormatter dateFromString:[dict objectForKey:@"created_at"]];
////    [dateFormatter setDateFormat:@"MM-dd-YYYY HH:mm:ss"];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict objectForKey:@"text"], [dict objectForKey:@"created_at"]];
	
    return cell;
}

- (void)dealloc {
    [twitterStatuses release];
    [twitterName release];
    [venueName release];
    [venueLabel release];
    [theTableView release];
    [super dealloc];
}

- (void)handleTweetNotification:(NSNotification *)notification {
    [self openWebView:[notification object]];
	NSLog(@"handleTweetNotification: notification = %@", notification);
}

#pragma mark UITableView methods

#pragma mark MGTwitterEngineDelegate methods

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    twitterStatuses = [[NSArray alloc] initWithArray:statuses];
    NSLog(@"number of tweets: %d", [twitterStatuses count]);
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:1];
    orderedTweets = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (NSDictionary *tweet in twitterStatuses) {
        [arr addObject:[tweet objectForKey:@"id"]];
    }
    orderedTweets = [[NSMutableDictionary alloc] initWithObjects:statuses forKeys:arr];
    NSArray *tempArray = [[NSArray alloc] initWithArray:[orderedTweets allKeys]];
    sortedKeys = [[NSArray alloc] initWithArray:[tempArray sortedArrayUsingSelector:@selector(compare:)]];
    [tempArray release];
    [theTableView reloadData];
}

//- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {
//    NSLog(@"directMessagesReceived: %@", messages);
//    
//}
//- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
//    NSLog(@"userInfoReceived: %@", userInfo);
//    
//}
//- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {
//    NSLog(@"miscInfoReceived: %@", miscInfo);
//    
//}
//- (void)connectionFinished:(NSString *)connectionIdentifier {
//    NSLog(@"connectionFinished: %@", connectionIdentifier);
//    
//}
- (void)requestSucceeded:(NSString *)connectionIdentifier {
    NSLog(@"requestSucceeded: %@", connectionIdentifier);
    
}
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
    NSLog(@"requestFailed: %@ - error: %@", connectionIdentifier, error);
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Twitter Error" andMessage:error];
    [self displayPopupMessage:message];
    [message release];
    
}
@end


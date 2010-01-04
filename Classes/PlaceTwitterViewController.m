//
//  PlaceTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/4/09.
//  Copyright 2009 Gorloch Interactive, LLC.. All rights reserved.
//

#import "PlaceTwitterViewController.h"
#import "MGTwitterEngine.h"

@implementation PlaceTwitterViewController

@synthesize twitterName, venueName;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: figure out why this isn't working (i.e., the navigation bar isn't being displayed)
    venueLabel.text = venueName;

    MGTwitterEngine *twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
    NSString *timeline = [twitterEngine getUserTimelineFor:twitterName sinceID:0 startingAtPage:0 count:20];
    NSLog(@"timeline: %@", timeline);
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
    return [twitterStatuses count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss GMT"];
    
    // Set up the cell...
    cell.textLabel.numberOfLines = 3;
    NSDictionary *dict = (NSDictionary*)[twitterStatuses objectAtIndex:indexPath.row];
//    NSLog(@"date: %@", [dict objectForKey:@"created_at"]);
//    NSDate *tweetDate = [dateFormatter dateFromString:[dict objectForKey:@"created_at"]];
//    [dateFormatter setDateFormat:@"MM-dd-YYYY HH:mm:ss"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict objectForKey:@"text"], [dict objectForKey:@"created_at"]];
    [dateFormatter release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (void)dealloc {
    [twitterStatuses release];
    [twitterName release];
    [venueName release];
    [venueLabel release];
    [theTableView release];
    [super dealloc];
}

#pragma mark UITableView methods

- (void) close {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark MGTwitterEngineDelegate methods

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    twitterStatuses = [[NSArray alloc] initWithArray:statuses];
    [theTableView reloadData];
    NSLog(@"statusesReceived: %@", statuses);
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
    NSLog(@"requestFailed: %@", connectionIdentifier);
    
}
@end


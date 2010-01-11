//
//  ProfileTwitterViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/11/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "ProfileTwitterViewController.h"


@implementation ProfileTwitterViewController

@synthesize tweets;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (void) dismiss {
    [self dismissModalViewControllerAnimated:YES];
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
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss GMT"];
    
    // Set up the cell...
    cell.textLabel.numberOfLines = 3;
    NSDictionary *dict = (NSDictionary*)[tweets objectAtIndex:indexPath.row];
    //    NSLog(@"date: %@", [dict objectForKey:@"created_at"]);
    //    NSDate *tweetDate = [dateFormatter dateFromString:[dict objectForKey:@"created_at"]];
    //    [dateFormatter setDateFormat:@"MM-dd-YYYY HH:mm:ss"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [dict objectForKey:@"text"], [dict objectForKey:@"created_at"]];
    [dateFormatter release];
	
    return cell;
}


- (void)dealloc {
    [theTableView release];
    [tweets release];
    [super dealloc];
}


@end


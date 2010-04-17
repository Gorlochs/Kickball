//
//  FriendSearchResultsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "FriendSearchResultsViewController.h"
#import "FSUser.h"
#import "ProfileViewController.h"

@implementation FriendSearchResultsViewController

@synthesize searchResults;

- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    [self addHeaderAndFooter:theTableView];
    [super viewDidLoad];

    NSLog(@"searchResults: %@", self.searchResults);
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
    return [self.searchResults count] == 0 ? 1 : [self.searchResults count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];  
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
    customView.backgroundColor = [UIColor whiteColor];
    customView.alpha = 0.85;
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor grayColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:12];
	headerLabel.frame = CGRectMake(10.0, 0.0, 320.0, 24.0);
    
    if ([self.searchResults count] > 0) {
        headerLabel.text = [NSString stringWithFormat:@"%d %@ Found", [self.searchResults count], [self.searchResults count] == 1 ? @"Friend" : @"Friends"];
    } else {
        [headerLabel release];
        return nil;
    }
	[customView addSubview:headerLabel];
    [headerLabel release];
    return customView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    
    if ([self.searchResults count] == 0) {
        cell.textLabel.text = @"No matching search results";
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = ((FSUser*)[self.searchResults objectAtIndex:indexPath.row]).fullname;
    }
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self displayProperProfileView:((FSUser*)[self.searchResults objectAtIndex:indexPath.row]).userId];
}

- (void)dealloc {
    [theTableView release];
    [searchResults release];
    [super dealloc];
}


@end


//
//  GeoApiDetailsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "GeoApiDetailsViewController.h"
#import "GAConnectionManager.h"
#import "SBJSON.h"

@implementation GeoApiDetailsViewController

@synthesize place;


- (void)viewDidLoad {
    [super viewDidLoad];

    GAConnectionManager *connectionManager_ = [[[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self] autorelease];
    [connectionManager_ requestListingForPlace:place.guid];
}

- (void)receivedResponseString:(NSString *)responseString {
    NSLog(@"geoapi response string: %@", responseString);
    
    //label.text = responseString;
    SBJSON *parser = [[SBJSON new] autorelease];
    id dict = [parser objectWithString:responseString error:NULL];
    NSDictionary *results = [(NSDictionary*)dict objectForKey:@"result"];
    
    place.address = [dict objectForKey:@"address"];
    place.listing = [[NSDictionary alloc] initWithDictionary:results];
    place.name = [results objectForKey:@"name"];
    
    [theTableView reloadData];

    NSLog(@"place listing: %@", place.listing);
}

- (void)requestFailed:(NSError *)error {
    NSLog(@"geoapi error string: %@", error);
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [place.listing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
        cell.detailTextLabel.numberOfLines = 3;
    }
    
    NSArray *keys = [place.listing allKeys];
    NSLog(@"key: %@", [keys objectAtIndex:indexPath.row]);
    NSLog(@"text: %@", [place.listing objectForKey:[keys objectAtIndex:indexPath.row]]);
    NSLog(@"text class: %@", [[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] class]);
    if (![[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = [keys objectAtIndex:indexPath.row];
        if ([[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSArray class]]) {
            NSArray *tmpArray = (NSArray*)[place.listing objectForKey:[keys objectAtIndex:indexPath.row]];
            cell.detailTextLabel.text = [tmpArray componentsJoinedByString:@", "];
        } else if ([[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = [place.listing objectForKey:[keys objectAtIndex:indexPath.row]];
        } else if ([[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSDecimalNumber class]]) {
            //cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", [place.listing objectForKey:[keys objectAtIndex:indexPath.row]]];
            cell.detailTextLabel.text = [[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] description];
        }   
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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


- (void)dealloc {
    [place release];
    [theTableView release];
    [super dealloc];
}


@end


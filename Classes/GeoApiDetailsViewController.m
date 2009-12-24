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

    GAConnectionManager *connectionManager_ = [[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self];
    [connectionManager_ requestListingForPlace:place.guid];
}

- (void)receivedResponseString:(NSString *)responseString {
    NSLog(@"geoapi response string: %@", responseString);
    
    //label.text = responseString;
    SBJSON *parser = [SBJSON new];
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


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [place.listing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
//        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
    }
    
    NSArray *keys = [place.listing allKeys];
    NSLog(@"key: %@", [keys objectAtIndex:indexPath.row]);
    NSLog(@"text: %@", [place.listing objectForKey:[keys objectAtIndex:indexPath.row]]);
    NSLog(@"text class: %@", [[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] class]);
    if (![[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSNull class]]) {
        if ([[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSArray class]]) {
            NSArray *tmpArray = (NSArray*)[place.listing objectForKey:[keys objectAtIndex:indexPath.row]];
            cell.textLabel.text = [tmpArray componentsJoinedByString:@"\n"];
            cell.textLabel.numberOfLines = [tmpArray count];
        } else if ([[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSString class]]) {
            cell.textLabel.text = [place.listing objectForKey:[keys objectAtIndex:indexPath.row]];
        } else if ([[place.listing objectForKey:[keys objectAtIndex:indexPath.row]] isKindOfClass:[NSDecimalNumber class]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%f", [place.listing objectForKey:[keys objectAtIndex:indexPath.row]]];
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


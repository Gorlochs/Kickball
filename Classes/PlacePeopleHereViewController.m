//
//  PlacePeopleHereViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacePeopleHereViewController.h"
#import "PlacePeopleHereTableCell.h"
#import "Three20/Three20.h"
#import "FSCheckin.h"


@implementation PlacePeopleHereViewController

@synthesize checkedInUsers;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    pageType = KBPageTypeOther;
    [self addHeaderAndFooter:theTableView];
    [super viewDidLoad];

    [self showBackHomeButtons];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [checkedInUsers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    PlacePeopleHereTableCell *cell = (PlacePeopleHereTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlacePeopleHereTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	FSCheckin *currentCheckin = ((FSCheckin*)[checkedInUsers objectAtIndex:indexPath.row]);
    cell.textLabel.text = currentCheckin.user.firstnameLastInitial;
    cell.userIcon.urlPath = currentCheckin.user.photo;
	return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0]];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSCheckin *tmpCheckin = ((FSCheckin*)[checkedInUsers objectAtIndex:indexPath.row]);
    [self displayProperProfileView:tmpCheckin.user.userId];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [checkedInUsers release];
    [super dealloc];
}


@end


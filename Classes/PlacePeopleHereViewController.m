//
//  PlacePeopleHereViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "PlacePeopleHereViewController.h"
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.detailTextLabel.numberOfLines = 1;
    cell.detailTextLabel.text = nil;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    FSCheckin *currentCheckin = ((FSCheckin*)[checkedInUsers objectAtIndex:indexPath.row]);
    cell.textLabel.text = currentCheckin.user.firstnameLastInitial;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"icon-default.png"];
    
    CGRect frame = CGRectMake(0,0,36,36);
    TTImageView *ttImage = [[[TTImageView alloc] initWithFrame:frame] autorelease];
    ttImage.urlPath = currentCheckin.user.photo;
    ttImage.backgroundColor = [UIColor clearColor];
    ttImage.defaultImage = [UIImage imageNamed:@"icon-default.png"];
    ttImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    [cell.imageView addSubview:ttImage];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0]];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSCheckin *tmpCheckin = ((FSCheckin*)[checkedInUsers objectAtIndex:indexPath.row]);
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
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


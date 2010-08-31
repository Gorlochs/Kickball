//
//  TipListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "TipListViewController.h"
#import "FSTip.h"
#import "TipListTableCell.h"

@implementation TipListViewController

@synthesize venue;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    pageType = KBPageTypeOther;
	tipController = nil;
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [venue.tips count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
    TipListTableCell *cell = (TipListTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TipListTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    FSTip *tip = (FSTip*)[venue.tips objectAtIndex:indexPath.row];
    cell.tipName.text = tip.submittedBy.firstnameLastInitial;
    cell.tipDetail.text = tip.text;
    cell.userIcon.urlPath = tip.submittedBy.photo;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTip *tip = ((FSTip*)[venue.tips objectAtIndex:indexPath.row]);
	if (tipController!=nil) {
		[tipController release];
		tipController = nil;
	}
    tipController = [[TipDetailViewController alloc] initWithNibName:@"TipView" bundle:nil];
    tipController.tip = tip;
    tipController.venue = venue;
    
    tipController.view.alpha = 0;
    
    [self.view addSubview:tipController.view];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.7];
    tipController.view.alpha = 1.0;        
    [UIView commitAnimations];
    
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [venue release];
    [tipController release];
    [super dealloc];
}


@end


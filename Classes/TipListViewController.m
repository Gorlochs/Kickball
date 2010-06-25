//
//  TipListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "TipListViewController.h"
#import "FSTip.h"

@implementation TipListViewController

@synthesize venue;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideRefresh = YES;
    pageType = KBPageTypeOther;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.detailTextLabel.numberOfLines = 2;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"blank_boy.png"];   
    }
    
    // Configure the cell...
    
    FSTip *tip = (FSTip*)[venue.tips objectAtIndex:indexPath.row];
    cell.textLabel.text = tip.submittedBy.firstnameLastInitial;
    cell.detailTextLabel.text = tip.text;
    
    CGRect frame = CGRectMake(9,9,36,36);
    TTImageView *ttImage = [[[TTImageView alloc] initWithFrame:frame] autorelease];
    ttImage.urlPath = tip.submittedBy.photo;
    ttImage.backgroundColor = [UIColor clearColor];
    ttImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
    ttImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    [cell addSubview:ttImage];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTip *tip = ((FSTip*)[venue.tips objectAtIndex:indexPath.row]);
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


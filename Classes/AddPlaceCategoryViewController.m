//
//  AddPlaceCategoryViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 5/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "AddPlaceCategoryViewController.h"
#import "FoursquareAPI.h"
#import "FSCategory.h"


@implementation AddPlaceCategoryViewController

@synthesize categories, newVenue;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    self.hideFooter = YES;
    self.hideHeader = YES;
    self.hideRefresh = YES;
    
    [super viewDidLoad];
    
    if (!categories) {
        [self startProgressBar:@"Retrieving categories..."];
        [[FoursquareAPI sharedInstance] getCategoriesWithTarget:self andAction:@selector(categoryResponseReceived:withResponseString:)];
    }
}

- (void)categoryResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    categories = [[FoursquareAPI categoriesFromResponseJSON:inString] retain];
    NSLog(@"categories: %@", categories);
    [theTableView reloadData];
    [self stopProgressBar];
}

- (void) backToAddAVenue {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [categories count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    FSCategory* category = (FSCategory*)[categories objectAtIndex:indexPath.row];
    cell.textLabel.text = category.nodeName;
    if (category.subcategories) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    FSCategory* category = (FSCategory*)[categories objectAtIndex:indexPath.row];
    if (category.subcategories) {
        AddPlaceCategoryViewController *formController = [[AddPlaceCategoryViewController alloc] initWithNibName:@"AddPlaceCategoryViewController" bundle:nil];
        formController.categories = category.subcategories;
        formController.newVenue = newVenue;
        [self.navigationController pushViewController:formController animated:YES];
        //[formController release];
    } else {
        newVenue.primaryCategory = category;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:newVenue, nil] 
                                                             forKeys:[NSArray arrayWithObjects:@"updatedVenue", nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"venueCategoryUpdate" object:nil userInfo:userInfo];
        //[self.navigationController popViewControllerAnimated:YES];
    }
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
    [categories release];
    [newVenue release];
    [super dealloc];
}


@end


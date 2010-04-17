//
//  OptionsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/16/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "OptionsViewController.h"
#import "FoursquareAPI.h"
#import "ViewFriendRequestsViewController.h"
#import "FriendRequestsViewController.h"


@implementation OptionsViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) viewWillAppear:(BOOL)animated {
    [self startProgressBar:@"Retrieving settings..."];
    [[FoursquareAPI sharedInstance] getPendingFriendRequests:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
    [super viewWillAppear:animated];
}
- (void
   )friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        NSLog(@"pending friend requests: %@", inString);
        pendingFriendRequests = [[FoursquareAPI usersFromRequestResponseXML:inString] retain];
        friendRequestCount.text = [NSString stringWithFormat:@"%d", [pendingFriendRequests count]];
    }
    [self stopProgressBar];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row == 0) {
        UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myDetailButton.frame = CGRectMake(0, 0, 320, 44);
        myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllTips01.png"] forState:UIControlStateNormal];
        [myDetailButton setImage:[UIImage imageNamed:@"profileSeeAllTips02.png"] forState:UIControlStateHighlighted];
        [myDetailButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside]; 
        [cell addSubview:myDetailButton];
    } else if (indexPath.row == 1) {
        UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myDetailButton.frame = CGRectMake(0, 0, 320, 44);
        myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [myDetailButton setImage:[UIImage imageNamed:@"profileHereToo01.png"] forState:UIControlStateNormal];
        [myDetailButton setImage:[UIImage imageNamed:@"profileHereToo02.png"] forState:UIControlStateHighlighted];
        [myDetailButton addTarget:self action:@selector(accountInfo) forControlEvents:UIControlEventTouchUpInside]; 
        [cell addSubview:myDetailButton];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark button methods

- (void) logout {
    NSLog(@"*************** logout ****************");
}

- (void) accountInfo {
    NSLog(@"*************** accountInfo ****************");
    
}

- (void) viewFriendRequests {
    ViewFriendRequestsViewController *friendRequestsController = [[ViewFriendRequestsViewController alloc] initWithNibName:@"ViewFriendRequestsViewController" bundle:nil];
    friendRequestsController.pendingFriendRequests = [[NSMutableArray alloc] initWithArray:pendingFriendRequests];
    [self.navigationController pushViewController:friendRequestsController animated:YES];
    [friendRequestsController release];
}

- (void) addFriends {
    FriendRequestsViewController *friendRequestsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    [self.navigationController pushViewController:friendRequestsController animated:YES];
    [friendRequestsController release];
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
    [super dealloc];
}


@end


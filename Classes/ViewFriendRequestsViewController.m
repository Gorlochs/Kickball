//
//  ViewFriendRequestsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 12/6/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "ViewFriendRequestsViewController.h"
#import "FoursquareAPI.h"
#import "FSUser.h"
#import "KBMessage.h"
#import "ViewFriendRequestsTableCell.h"

@implementation ViewFriendRequestsViewController

@synthesize pendingFriendRequests;

- (void)viewDidLoad {
    [[Beacon shared] startSubBeaconWithName:@"View Pending Friend Requests"];
    [super viewDidLoad];
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
    return [pendingFriendRequests count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FriendRequestCell";
    
    ViewFriendRequestsTableCell *cell = (ViewFriendRequestsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {        
        UIViewController *vc = [[UIViewController alloc]initWithNibName:@"ViewFriendRequestsTableCell" bundle:nil];
        cell = (ViewFriendRequestsTableCell*) vc.view;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        [vc release];
    }
    
    cell.acceptFriendButton.tag = indexPath.row;
    cell.friendName.text = ((FSUser*)[pendingFriendRequests objectAtIndex:indexPath.row]).firstnameLastInitial;
    [cell.acceptFriendButton addTarget:self action:@selector(acceptFriend:) forControlEvents:UIControlEventTouchUpInside];
    [cell.denyFriendButton addTarget:self action:@selector(denyFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"pending friend requests: %@", inString);
    FSUser *user = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    NSLog(@"approved user: %@", user);
    
    KBMessage *message = nil;
    if (user) {
        message = [[KBMessage alloc] initWithMember:@"Friend Request Approved" andMessage:@"You now have a new buddy."];
        int i = 0;
        for (FSUser *u in pendingFriendRequests) {
            if ([user.userId isEqualToString:u.userId]) {
                // need a better isEqual method for FSUser so I can use removeObject:
                
                [pendingFriendRequests removeObjectAtIndex:i];
                [theTableView reloadData];
                break;
            }
            i++;
        }
    } else {
        message = [[KBMessage alloc] initWithMember:@"Friend Request Error" andMessage:@"Something went wrong."];
    }
    [self displayPopupMessage:message];
    [message release];
}

- (void) acceptFriend:(UIControl*) button {
    [[Beacon shared] startSubBeaconWithName:@"Accept Friend"];
    NSLog(@"acceptfriend tag: %d", button.tag);
    [self startProgressBar:@"Accepting your new friend..."];
    [[FoursquareAPI sharedInstance] approveFriendRequest:((FSUser*)[pendingFriendRequests objectAtIndex:button.tag]).userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
}

- (void) denyFriend:(UIControl*) button {
    [[Beacon shared] startSubBeaconWithName:@"Deny Friend"];
    NSLog(@"denyfriend tag: %d", button.tag);
    [self startProgressBar:@"Denying your new friend..."];
    [[FoursquareAPI sharedInstance] denyFriendRequest:((FSUser*)[pendingFriendRequests objectAtIndex:button.tag]).userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
}

- (void)dealloc {
    [pendingFriendRequests release];
    [theTableView release];
    [super dealloc];
}


@end


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
#import "ProfileViewController.h"

@implementation ViewFriendRequestsViewController

@synthesize pendingFriendRequests;

- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    [FlurryAPI logEvent:@"View Pending Friend Requests"];
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
    return [pendingFriendRequests count] == 0 ? 1 : [pendingFriendRequests count];
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
    
    if ([pendingFriendRequests count] == 0) {
        cell.friendName.text = @"No current friend requests";
        cell.acceptFriendButton.hidden = YES;
        cell.denyFriendButton.hidden = YES;
        cell.rowCarat.hidden = YES;
    } else {
        cell.acceptFriendButton.tag = indexPath.row;
        cell.friendName.text = ((FSUser*)[pendingFriendRequests objectAtIndex:indexPath.row]).firstnameLastInitial;
        cell.acceptFriendButton.hidden = NO;
        cell.denyFriendButton.hidden = NO;
        cell.rowCarat.hidden = NO;
        [cell.acceptFriendButton addTarget:self action:@selector(acceptFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.denyFriendButton addTarget:self action:@selector(denyFriend:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self displayProperProfileView:((FSUser*)[pendingFriendRequests objectAtIndex:indexPath.row]).userId];
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"pending friend requests: %@", inString);
    FSUser *user = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    DLog(@"approved user: %@", user);
    
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

// cheap and crappy, but I don't have the time
- (void)denyFriendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"pending friend requests: %@", inString);
    FSUser *user = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    DLog(@"approved user: %@", user);
    
    KBMessage *message = nil;
    if (user) {
        message = [[KBMessage alloc] initWithMember:@"Friend Request Denied" andMessage:@"Sorry buddy, not this time!"];
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
    [FlurryAPI logEvent:@"Accept Friend"];
    DLog(@"acceptfriend tag: %d", button.tag);
    [self startProgressBar:@"Accepting your new friend..."];
    [[FoursquareAPI sharedInstance] approveFriendRequest:((FSUser*)[pendingFriendRequests objectAtIndex:button.tag]).userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
}

- (void) denyFriend:(UIControl*) button {
    [FlurryAPI logEvent:@"Deny Friend"];
    DLog(@"denyfriend tag: %d", button.tag);
    [self startProgressBar:@"Denying your new friend..."];
    [[FoursquareAPI sharedInstance] denyFriendRequest:((FSUser*)[pendingFriendRequests objectAtIndex:button.tag]).userId withTarget:self andAction:@selector(denyFriendRequestResponseReceived:withResponseString:)];
}

- (void)dealloc {
    [pendingFriendRequests release];
    [super dealloc];
}


@end


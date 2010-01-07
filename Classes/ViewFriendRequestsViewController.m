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

@implementation ViewFriendRequestsViewController

@synthesize pendingFriendRequests;

- (void)viewDidLoad {
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = ((FSUser*)[pendingFriendRequests objectAtIndex:indexPath.row]).firstnameLastInitial;
	// TODO: create two buttons, accept and deny; set button.tag to help identify which button is touched
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self startProgressBar:@"Approving user..."];
    [[FoursquareAPI sharedInstance] approveFriendRequest:((FSUser*)[pendingFriendRequests objectAtIndex:indexPath.row]).userId withTarget:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"pending friend requests: %@", inString);
    FSUser *user = [FoursquareAPI userFromResponseXML:inString];
    [self stopProgressBar];
    NSLog(@"approved user: %@", user);
    
    KBMessage *message = nil;
    if (user) {
        message = [[KBMessage alloc] initWithMember:@"Friend Request" andSubtitle:@"Approved!" andMessage:@"You now have a new buddy."];
        int i = 0;
        for (FSUser *u in pendingFriendRequests) {
            if (user.userId == u.userId) {
                [pendingFriendRequests removeObjectAtIndex:i];
                [theTableView reloadData];
                break;
            }
            i++;
        }
    } else {
        message = [[KBMessage alloc] initWithMember:@"Friend Request" andSubtitle:@"Error!" andMessage:@"Something went wrong."];
    }
    [self displayPopupMessage:message];
    [message release];
}

- (void)dealloc {
    [theTableView release];
    [super dealloc];
}


@end


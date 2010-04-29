//
//  KBTwitterUserListViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterUserListViewController.h"
#import "KBTwitterUser.h"
#import "KBTwitterUserTableCell.h"

@implementation KBTwitterUserListViewController

@synthesize userDictionary;
@synthesize userType;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeList;
    hideRefresh = YES;
    [super viewDidLoad];
    
    [self showStatuses];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersRetrieved:) name:kTwitterUserInfoRetrievedNotificationKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    if (userType == KBTwitterUserFollower) {
        [twitterEngine getFollowersForUser:[userDictionary objectForKey:@"screen_name"]];
    } else {
        [twitterEngine getFriendsForUser:[userDictionary objectForKey:@"screen_name"]];
    }
    
}

- (void) usersRetrieved:(NSNotification *)inNotification {
    NSLog(@"notification: %@", inNotification);
    if (inNotification && [inNotification userInfo]) {
        NSDictionary *userInfo = [inNotification userInfo];
        if ([userInfo objectForKey:@"userInfo"]) {
            statuses = [[userInfo objectForKey:@"userInfo"] retain];
            //NSLog(@"users retrieved: %@", users);
            users = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
            for (NSDictionary *dict in statuses) {
                [users addObject:[[KBTwitterUser alloc] initWithDictionary:dict]];
            }
            [theTableView reloadData];
        }
    }
    [self stopProgressBar];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) executeQuery:(int)pageNumber {
    [twitterEngine getRepliesSinceID:0 startingAtPage:pageNumber count:25];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [users count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTwitterUserTableCell *cell = (KBTwitterUserTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTwitterUserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    KBTwitterUser *user = [users objectAtIndex:indexPath.row];
    cell.userName.text = user.fullName;    
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
    [userDictionary release];
    [users release];
    [super dealloc];
}


@end


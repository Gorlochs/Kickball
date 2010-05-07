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
#import "KBTwitterProfileViewController.h"


@implementation KBTwitterUserListViewController

@synthesize userDictionary;
@synthesize userType;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    pageViewType = KBPageViewTypeList;
    hideRefresh = YES;
    [super viewDidLoad];
    
    if (!currentCursor) {
        currentCursor = [NSNumber numberWithInt:-1];
    }
    
    [self showStatuses];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersRetrieved:) name:kTwitterUserInfoRetrievedNotificationKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    // it was either this, or extending this class and overriding one method. 
    [self startProgressBar:@"Retrieving users..."];
    if (userType == KBTwitterUserFollower) {
        [twitterEngine getFollowersForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
    } else {
        [twitterEngine getFriendsForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
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
                KBTwitterUser *user = [[KBTwitterUser alloc] initWithDictionary:dict];
                [users addObject:user];
                [user release];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    KBTwitterUser *user = [users objectAtIndex:indexPath.row];
    cell.userName.text = user.fullName;
    cell.userIcon.urlPath = user.profileImageUrl;
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	KBTwitterProfileViewController *profileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
    profileController.screenname = ((KBTwitterUser*)[users objectAtIndex:indexPath.row]).screenName;
	[self.navigationController pushViewController:profileController animated:YES];
	[profileController release];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [userDictionary release];
    [users release];
    [super dealloc];
}


@end


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
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeList;
    hideRefresh = YES;
    [super viewDidLoad];
    
    //if (!currentCursor) {
        currentCursor = [NSNumber numberWithInt:-1];
    //}
    
    [self showStatuses];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersRetrieved:) name:kTwitterUserInfoRetrievedNotificationKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    [self executeQuery:0];
}

- (void) usersRetrieved:(NSNotification *)inNotification {
    NSLog(@"notification: %@", inNotification);
    if (inNotification && [inNotification userInfo]) {
        NSDictionary *userInfo = [inNotification userInfo];
        if ([userInfo objectForKey:@"userInfo"]) {
            statuses = [[[[userInfo objectForKey:@"userInfo"] objectAtIndex:0] objectForKey:@"users"] retain];
            
            NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[statuses count]];
            for (NSDictionary *dict in statuses) {
                KBTwitterUser *user = [[KBTwitterUser alloc] initWithDictionary:dict];
                [tempTweetArray addObject:user];
                [user release];
            }
            
            if (currentCursor != [NSNumber numberWithInt:-1]) {
                [users addObjectsFromArray:tempTweetArray];
            } else if (!users) {
                users = [[NSMutableArray alloc] initWithArray:tempTweetArray];
            } else {
                // need to keep all the tweets in the right order
                [tempTweetArray addObjectsFromArray:users];
                users = nil;
                [users release];
                users = [[NSMutableArray alloc] initWithArray:tempTweetArray];
            }
            [tempTweetArray release];

            [theTableView reloadData];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            currentCursor = [[f numberFromString:[[[userInfo objectForKey:@"userInfo"] objectAtIndex:0] objectForKey:@"next_cursor_str"]] retain];
            [f release];
        }
    }
    [self stopProgressBar];
}

- (void) executeQuery:(int)pageNumber {
    [self startProgressBar:@"Retrieving users..."];
    if (userType == KBTwitterUserFollower) {
        [twitterEngine getFollowersForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
    } else {
        [twitterEngine getFriendsForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return section == 0 ? [users count] : 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTwitterUserTableCell *cell = (KBTwitterUserTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTwitterUserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        // Configure the cell...
        KBTwitterUser *user = [users objectAtIndex:indexPath.row];
        cell.userName.text = user.fullName;
        cell.userIcon.urlPath = user.profileImageUrl;
        return cell;
    } else {
        return moreCell;
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        KBTwitterProfileViewController *profileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
        profileController.screenname = ((KBTwitterUser*)[users objectAtIndex:indexPath.row]).screenName;
        [self.navigationController pushViewController:profileController animated:YES];
        [profileController release];
    } else {
        [self executeQuery:++pageNum];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [userDictionary release];
    [users release];
    [currentCursor release];
    [super dealloc];
}


@end


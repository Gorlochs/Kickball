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
#import "TableSectionHeaderView.h"


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
    
    currentCursor = [NSNumber numberWithInt:-1];
    
    [self showStatuses];
    
    [timelineButton setImage:[UIImage imageNamed:@"tabTweets03.png"] forState:UIControlStateNormal];
    [mentionsButton setImage:[UIImage imageNamed:@"tabMentions03.png"] forState:UIControlStateNormal];
    [directMessageButton setImage:[UIImage imageNamed:@"tabDM03.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage imageNamed:@"tabSearch03.png"] forState:UIControlStateNormal];
}

- (void) showStatuses {
    [self executeQuery:0];
}

- (void)statusesReceived:(NSArray *)statuses {
  //this classes super doesn't *have* a statusesReceived... [super statusesReceived:statuses];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [users count] - 1) {
        if (requeryWhenTableGetsToBottom) {
            [self executeQuery:++pageNum];
        } else {
            DLog("********************* REACHED NO MORE RESULTS!!!!! **********************");
        }
	}
}

- (void)userInfoReceived:(NSArray *)userInfo {
	if (userInfo) {
		NSArray *twitterArray = [[userInfo objectAtIndex:0] objectForKey:@"users"];
		
		NSMutableArray *tempTweetArray = [[NSMutableArray alloc] initWithCapacity:[twitterArray count]];
		for (NSDictionary *dict in twitterArray) {
			KBTwitterUser *user = [[KBTwitterUser alloc] initWithDictionary:dict];
			[tempTweetArray addObject:user];
			[user release];
		}
		
        //FIXME: add directly to users instead of swapping two arrays
		if (currentCursor != [NSNumber numberWithInt:-1]) {
			[users addObjectsFromArray:tempTweetArray];
		} else if (!users) {
			users = [[NSMutableArray alloc] initWithArray:tempTweetArray];
		} else {
			// need to keep all the tweets in the right order
			[tempTweetArray addObjectsFromArray:users];
			[users release];
			users = nil;
			users = [[NSMutableArray alloc] initWithArray:tempTweetArray];
		}
		[tempTweetArray release];
		[theTableView reloadData];
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		currentCursor = [[f numberFromString:[[userInfo objectAtIndex:0] objectForKey:@"next_cursor_str"]] retain];
		[f release];
	}
    [self stopProgressBar];
}


- (void) executeQuery:(int)pageNumber {
    [self startProgressBar:@"Retrieving users..."];
    if (userType == KBTwitterUserFollower) {
        [twitterEngine getFollowersForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor atPage:pageNumber];
    } else if (userType == KBTwitterUserFriend) {
        [twitterEngine getFriendsForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
    } else if (userType == KBTwitterUserFavorites) {
        [twitterEngine getFavoritesForUser:[userDictionary objectForKey:@"screen_name"] withCursor:currentCursor];
    }
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTwitterUserTableCell *cell = (KBTwitterUserTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTwitterUserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.userName.highlightedTextColor = [UIColor whiteColor];
    }
    
	KBTwitterUser *user = [users objectAtIndex:indexPath.row];
	cell.userName.text = user.fullName;
	cell.userIcon.urlPath = user.profileImageUrl;
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableSectionHeaderView *sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
	
    if (userType == KBTwitterUserFollower) {
        sectionHeaderView.leftHeaderLabel.text = [NSString stringWithFormat:@"%@'s followers", [userDictionary objectForKey:@"screen_name"]];
    } else if (userType == KBTwitterUserFriend) {
		sectionHeaderView.leftHeaderLabel.text = [NSString stringWithFormat:@"users %@ is following", [userDictionary objectForKey:@"screen_name"]];
	}
	
	return sectionHeaderView;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	KBTwitterProfileViewController *twitterProfileController = [[KBTwitterProfileViewController alloc] initWithNibName:@"KBTwitterProfileViewController" bundle:nil];
	twitterProfileController.screenname = ((KBTwitterUser*)[users objectAtIndex:indexPath.row]).screenName;
	[self.navigationController pushViewController:twitterProfileController animated:YES];
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	[twitterProfileController release];
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
    if (users) [users release];
    if (currentCursor) [currentCursor release];
    [super dealloc];
}


@end


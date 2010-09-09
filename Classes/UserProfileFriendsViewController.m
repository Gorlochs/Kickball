    //
//  UserProfileFriendsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "UserProfileFriendsViewController.h"
#import	"TableSectionHeaderView.h"
#import "FSUser.h"
#import "PlacePeopleHereTableCell.h"

@implementation UserProfileFriendsViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    yourFriendsButton.enabled = NO;
    yourStuffButton.enabled = YES;
    checkinHistoryButton.enabled = YES;
    //[yourStuffButton setImage:[UIImage imageNamed:@"myProfileStuffTab02.png"] forState:UIControlStateNormal];
    //[yourFriendsButton setImage:[UIImage imageNamed:@"myProfileFriendsTab01.png"] forState:UIControlStateDisabled];
    //[checkinHistoryButton setImage:[UIImage imageNamed:@"myProfileHistoryTab03.png"] forState:UIControlStateNormal];
	
	filterType = KBFriendsFilterAll;
    //[friendToggle addTarget:self action:@selector(filterFriendsList) forControlEvents:UIControlEventValueChanged];
	
	for (FSUser *theUser in friends) {
		if (theUser.sendsPingsToSignedInUser) {
			numFriendsWithPings++;
		}
	}
}

- (void) executeFoursquareCalls {
    [self startProgressBar:@"Retrieving friends..."];
    [[FoursquareAPI sharedInstance] getFriendsWithUserIdAndTarget:userId andTarget:self andAction:@selector(friendsResponseReceived:withResponseString:)];
    [FlurryAPI logEvent:@"View Users Friends"];
}


- (void)friendsResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"friends: %@", inString);
	if (friends!=nil) {
		[friends release];
		friends = nil;
	}
    friends = [[FoursquareAPI friendUsersFromRequestResponseXML:inString] retain];
    [theTableView reloadData];
    [self stopProgressBar];
    theTableView.hidden = NO;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//	if (section == 1) {
//		return 1;
//	} else {
		if (filterType == KBFriendsFilterAll) {
			return [friends count];
		} else if (filterType == KBFriendsFilterPing) {
			return numFriendsWithPings;
		} else {
			return [friends count] - numFriendsWithPings;
		}
//	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
    
    PlacePeopleHereTableCell *cell = (PlacePeopleHereTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PlacePeopleHereTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	

	FSUser *theUser = (FSUser*)[friends objectAtIndex:indexPath.row];
	if (filterType == KBFriendsFilterAll || (filterType == KBFriendsFilterPing && theUser.sendsPingsToSignedInUser) || (filterType == KBFriendsFilterNoPing && !theUser.sendsPingsToSignedInUser)) {
		
		cell.textLabel.text = theUser.firstnameLastInitial;
		
		cell.userIcon.urlPath = theUser.photo;
		
		/*
		float sw=32/cell.imageView.image.size.width;
		float sh=32/cell.imageView.image.size.height;
		cell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
		cell.imageView.layer.masksToBounds = YES;
		cell.imageView.layer.cornerRadius = 8.0; 
		 */
		
		return cell;
	} else {
		return nil;
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self displayProperProfileView:((FSUser*)[friends objectAtIndex:indexPath.row]).userId];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //BlackTableCellHeader *sectionHeaderView = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)] autorelease];
	TableSectionHeaderView *sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)] autorelease];
	sectionHeaderView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d Friends", [friends count]];
    //sectionHeaderView.leftHeaderLabel.textColor = [UIColor whiteColor];
    return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
}

- (void) filterFriendsList {
	if (friendToggle.selectedSegmentIndex == 0) {
		filterType = KBFriendsFilterAll;
	} else if (friendToggle.selectedSegmentIndex == 1) {
		filterType = KBFriendsFilterPing;
	} else {
		filterType = KBFriendsFilterNoPing;
	}
	[theTableView reloadData];
}

#pragma mark 
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [friends release];
    [super dealloc];
}


@end

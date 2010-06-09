    //
//  UserProfileFriendsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/15/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "UserProfileFriendsViewController.h"
#import "FSUser.h"

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
    [yourStuffButton setImage:[UIImage imageNamed:@"myProfileStuffTab02.png"] forState:UIControlStateNormal];
    [yourFriendsButton setImage:[UIImage imageNamed:@"myProfileFriendsTab01.png"] forState:UIControlStateDisabled];
    [checkinHistoryButton setImage:[UIImage imageNamed:@"myProfileHistoryTab03.png"] forState:UIControlStateNormal];
	
	filterType = KBFriendsFilterAll;
    [friendToggle addTarget:self action:@selector(filterFriendsList) forControlEvents:UIControlEventValueChanged];
	
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
    friends = [[FoursquareAPI friendUsersFromRequestResponseXML:inString] retain];
    [theTableView reloadData];
    [self stopProgressBar];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 1) {
		return 1;
	} else {
		if (filterType == KBFriendsFilterAll) {
			return [friends count];
		} else if (filterType == KBFriendsFilterPing) {
			return numFriendsWithPings;
		} else {
			return [friends count] - numFriendsWithPings;
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"blank_boy.png"];   
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        
        UIImageView *topLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderTop.png"]];
        topLineImage.frame = CGRectMake(0, 0, cell.frame.size.width, 1);
        [cell addSubview:topLineImage];
        [topLineImage release];
        
        // TODO: the origin.y should probably not be hard coded
        UIImageView *bottomLineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBorderBottom.png"]];
        bottomLineImage.frame = CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1);
        [cell addSubview:bottomLineImage];
        [bottomLineImage release];
    }
    
	if (indexPath.section == 1) {
		return friendToggleCell;
	} else {
		FSUser *theUser = (FSUser*)[friends objectAtIndex:indexPath.row];
		if (filterType == KBFriendsFilterAll || (filterType == KBFriendsFilterPing && theUser.sendsPingsToSignedInUser) || (filterType == KBFriendsFilterNoPing && !theUser.sendsPingsToSignedInUser)) {
			
			cell.textLabel.text = theUser.firstnameLastInitial;
			
			CGRect frame = CGRectMake(4,4,36,36);
			TTImageView *ttImage = [[[TTImageView alloc] initWithFrame:frame] autorelease];
			ttImage.urlPath = theUser.photo;
			ttImage.backgroundColor = [UIColor clearColor];
			ttImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
			ttImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
			[cell addSubview:ttImage];
			
			float sw=32/cell.imageView.image.size.width;
			float sh=32/cell.imageView.image.size.height;
			cell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
			cell.imageView.layer.masksToBounds = YES;
			cell.imageView.layer.cornerRadius = 8.0; 
			
			return cell;
		} else {
			return nil;
		}
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self displayProperProfileView:((FSUser*)[friends objectAtIndex:indexPath.row]).userId];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    BlackTableCellHeader *headerView = [[[BlackTableCellHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 36)] autorelease];
    headerView.leftHeaderLabel.text = [NSString stringWithFormat:@"%d Friends", [friends count]];
    headerView.leftHeaderLabel.textColor = [UIColor whiteColor];
    return headerView;
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

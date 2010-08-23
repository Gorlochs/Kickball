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
#import "AccountOptionsViewController.h"
#import "VersionInfoViewController.h"
#import "FriendPriorityOptionViewController.h"
#import "FeedbackViewController.h"
#import "CheckinOptionsViewController.h"
#import "KickballAppDelegate.h"
#import "OptionsNavigationController.h"


@implementation OptionsViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.hideHeader = YES;
    self.hideFooter = YES;
    self.hideRefresh = YES;
    
    cellArray = [[NSArray alloc] initWithObjects:quickCheckInCell, defaultCheckinCell, accountInformationCell, pushNotificationCell,friendsListPriorityCell, feedbackCell, versionInformationsCell, nil];
    
    [super viewDidLoad];
 
    [pushNotificationSwitch setOn:[[FoursquareAPI sharedInstance] currentUser].isPingOn];
	[quickCheckInSwitch setOn:[[Utilities sharedInstance] isInstacheckinOn]];
}

- (void) viewWillAppear:(BOOL)animated {
    //[self startProgressBar:@"Retrieving settings..."];
	[self retrieveFriendRequests];
    [super viewWillAppear:animated];
	[theTableView scrollToFirstRow:NO];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showNoOptionsButts];
	NSArray *newStack = [NSArray arrayWithObjects:self,nil];
	[[self navigationController] setViewControllers:newStack animated:NO];
}

- (void)friendRequestResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSString *errorMessage = [FoursquareAPI errorFromResponseXML:inString];
    if (errorMessage) {
        [self displayFoursquareErrorMessage:errorMessage];
    } else {
        DLog(@"pending friend requests: %@", inString);
		if (pendingFriendRequests!=nil) {
			[pendingFriendRequests release];
			pendingFriendRequests = nil;
		}
        pendingFriendRequests = [[FoursquareAPI usersFromRequestResponseXML:inString] retain];
        friendRequestCount.text = [NSString stringWithFormat:@"%d", [pendingFriendRequests count]];
    }
    [self stopProgressBar];
}

- (void) retrieveFriendRequests {
	if([[KBAccountManager sharedInstance] usesFoursquare]){
		[[FoursquareAPI sharedInstance] getPendingFriendRequests:self andAction:@selector(friendRequestResponseReceived:withResponseString:)];
	}
}

- (void) displayFoursquareErrorMessage:(NSString*)errorMessage {
    KBMessage *message = [[KBMessage alloc] initWithMember:@"Foursquare Error" andMessage:errorMessage isError:YES];
    [self displayPopupMessage:message];
    [message release];
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//
//    
//    return cell;
    
    return [cellArray objectAtIndex:indexPath.row];
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

-(void)pressOptionsLeft{
	
}
-(void)pressOptionsRight{
	
}

- (void) logout {
    DLog(@"*************** logout ****************");
}

- (void) viewAccountOptions {
    //AccountOptionsViewController *accountController = [[AccountOptionsViewController alloc] initWithNibName:@"AccountOptionsView_v2" bundle:nil];
    [self.navigationController pushViewController:[(OptionsNavigationController*)self.parentViewController account] animated:YES];
    //[accountController release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBothOptionsButts];
}

- (void) viewVersion {
    //VersionInfoViewController *controller = [[VersionInfoViewController alloc] initWithNibName:@"VersionInfoViewController" bundle:nil];
    [self.navigationController pushViewController:[(OptionsNavigationController*)self.parentViewController versionInfo] animated:YES];
    //[controller release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBothOptionsButts];

}

- (void) viewFriendPriority {
    //FriendPriorityOptionViewController *controller = [[FriendPriorityOptionViewController alloc] initWithNibName:@"FriendPriorityOptionViewController" bundle:nil];
    [self.navigationController pushViewController:[(OptionsNavigationController*)self.parentViewController friendPriority] animated:YES];
    //[controller release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBothOptionsButts];

}

- (void) viewFeedback {
   //FeedbackViewController *controller = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    [self.navigationController pushViewController:[(OptionsNavigationController*)self.parentViewController feedback] animated:YES];
    //[controller release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBothOptionsButts];

}



- (void) viewDefaultCheckinOptions {
    //CheckinOptionsViewController *controller = [[CheckinOptionsViewController alloc] initWithNibName:@"CheckinOptionsViewController" bundle:nil];
    [self.navigationController pushViewController:[(OptionsNavigationController*)self.parentViewController checkin] animated:YES];
    //[controller release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showBothOptionsButts];

}

- (void) addFriends {
    //FriendRequestsViewController *friendRequestsController = [[FriendRequestsViewController alloc] initWithNibName:@"FriendRequestsViewController" bundle:nil];
    //[self.navigationController pushViewController:friendRequestsController animated:YES];
    //[friendRequestsController release];
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showNoOptionsButts];
	[appDelegate showAddFriends];

}

- (void) viewFriendRequests {
    /*ViewFriendRequestsViewController *controller = [[ViewFriendRequestsViewController alloc] initWithNibName:@"ViewFriendRequestsViewController" bundle:nil];
    controller.pendingFriendRequests = [[NSMutableArray alloc] initWithArray:pendingFriendRequests];
	[self.navigationController.view setFrame:CGRectMake(0, 0, 320, 480)];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
	*/
	KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appDelegate showNoOptionsButts];
	[appDelegate showFriendRequests:pendingFriendRequests];
	
}

#pragma mark -
#pragma mark IBActions

- (void) togglePushNotifications {
    [self startProgressBar:@"Changing your ping update preferences..."];
    NSString *ping = @"off";
    if (pushNotificationSwitch.on) {
        ping = @"on";
    }
    [[FoursquareAPI sharedInstance] setPings:ping forUser:@"self" withTarget:self andAction:@selector(pingUpdateResponseReceived:withResponseString:)];
}

- (void) toggleInstacheckin {
	[[Utilities sharedInstance] setIsInstacheckinOn:quickCheckInSwitch.on];
}

- (void) pingUpdateResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"instring: %@", inString);
    BOOL newPingSetting = [FoursquareAPI pingSettingFromResponseXML:inString];
    DLog(@"new ping setting: %d", newPingSetting);
    [self stopProgressBar];
    [[FoursquareAPI sharedInstance] currentUser].isPingOn = newPingSetting;
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


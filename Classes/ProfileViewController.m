//
//  ProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 10/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "FoursquareAPI.h"
#import "FSVenue.h"
#import "PlaceDetailViewController.h"
#import "MGTwitterEngine.h"

#define BADGES_PER_ROW 5

@interface ProfileViewController (Private)

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) displayActionSheet:(NSString*)title;

@end

@implementation ProfileViewController

@synthesize userId, badgeCell;


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    name.text = @"";
    location.text = @"";
    lastCheckinAddress.text = @"";
    
    if(![[FoursquareAPI sharedInstance] isAuthenticated]){
		//run sheet to log in.
		NSLog(@"Foursquare is not authenticated");
	} else {
        // TODO: will also have to make a call to our DB to get gift info
        [[FoursquareAPI sharedInstance] getUser:self.userId withTarget:self andAction:@selector(userResponseReceived:withResponseString:)];
	}
}

- (void)userResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
	user = [FoursquareAPI userFromResponseXML:inString];
    name.text = user.firstnameLastInitial;
//    location.text = user.
    
    // user icon
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.photo]];
    UIImage *img = [[UIImage alloc] initWithData:data];
    userIcon.image = img;
    [img release];
    
    // badges
    // I was hoping for something elegant, and it seemed like I was going to get there, but, as you can see, I didn't quite make it
    // I'm sure there's a better way to do this, but this works.
    int x = 0;
    int y = 0;
    for (FSBadge *badge in user.badges) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:badge.icon]];
        CGRect frame= CGRectMake(x*60 + 10, y*60 + 10, 50, 50);
        UIButton *btn = [[UIButton alloc] initWithFrame:frame];
        UIImage *img = [[UIImage alloc] initWithData:data];
        [btn setImage:img forState:UIControlStateNormal];
        btn.tag = [badge.badgeId intValue];
        [badgeCell addSubview:btn];
        [badgeCell bringSubviewToFront:btn];
        [img release];
        
//        UIImage *img = [[UIImage alloc] initWithData:data];
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
//        CGRect frame= CGRectMake(x*60 + 10, y*60 + 10, 50, 50);
//        imgView.frame = frame;
//        [img release];
//        [badgeCell addSubview:imgView];
//        [imgView release];
        x++;
        if (x%BADGES_PER_ROW == 0) {
            x = 0;
            y++;
        }
    }
    
	[theTableView reloadData];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    theTableView = nil;
    
    name = nil;
    lastCheckinAddress = nil;
    nightsOut = nil;
    totalCheckins = nil;
    userIcon = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    name = nil;
    lastCheckinAddress = nil;
    nightsOut = nil;
    totalCheckins = nil;
    userIcon = nil;
}


- (void)dealloc {
    [theTableView release];
    
    [name release];
    [lastCheckinAddress release];
    [nightsOut release];
    [totalCheckins release];
    [userIcon release];
    
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return [user.mayorOf count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        //return 50 * (([user.badges count]/BADGES_PER_ROW) + 1);
        return 60 * (([user.badges count]+2)/BADGES_PER_ROW) + 10;
    }
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 0) {
            return addFriendCell;
        } else if (indexPath.section == 1) {
            return badgeCell;
        } else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    
    // Set up the cell...
    switch (indexPath.section) {
        case 0:  // add friend/follow on twitter
            return addFriendCell;
            break;
        case 1:  // badges
            return badgeCell;
            break;
        case 2:  // mayors
            cell.textLabel.text = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).name;
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 24.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NULL;
    } else {
        // create the parent view that will hold header Label
        UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)] autorelease];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor blackColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor grayColor];
        headerLabel.highlightedTextColor = [UIColor grayColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        headerLabel.frame = CGRectMake(0.0, 0.0, 320.0, 24.0);
        
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
        switch (section) {
            case 0:
                break;
            case 1:
                // TODO: fix this
                headerLabel.text = @"  Badges";
                break;
            case 2:
                headerLabel.text = @"  Mayor";
                break;
            default:
                headerLabel.text = @"You shouldn't see this";
                break;
        }
        //headerLabel.text = <Put here whatever you want to display> // i.e. array element
        [customView addSubview:headerLabel];
        [headerLabel release];
        return customView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) { // mayor section
        PlaceDetailViewController *placeDetailController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
        placeDetailController.venueId = ((FSVenue*)[user.mayorOf objectAtIndex:indexPath.row]).venueid;
        [self.navigationController pushViewController:placeDetailController animated:YES];
        [placeDetailController release];
    }
}

#pragma mark IBAction methods

- (void) clickSegmentedControl {
    NSString *title = nil;
    if (segmentedControl.selectedSegmentIndex == 0) {
        title = @"Yes, open SMS app";
        [self displayActionSheet:title];
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        title = @"Yes, open Phone app";
        [self displayActionSheet:title];
    } else if (segmentedControl.selectedSegmentIndex == 2) {
        title = @"Yes, open Mail app";
        [self displayActionSheet:title];
    } else if (segmentedControl.selectedSegmentIndex == 3) {
        // display twitter table
        
        // TODO: figure out the best way to deal with the UITableViewDelegate methods with this table
        //       I don't want to use the ones in this controller (too big a pain in the ass)
        //       I guess I can just create a new controller and use that.
        MGTwitterEngine *twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
        NSString *twitters = [twitterEngine getUserTimelineFor:user.twitter sinceID:0 startingAtPage:0 count:20];
        NSLog(@"twitter: %@", twitters);
    } else if (segmentedControl.selectedSegmentIndex == 4) {
        title = @"Yes, open Facebook app";
        [self displayActionSheet:title];
    }
}
- (void) displayActionSheet:(NSString*)title {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"You will be leaving the Kickball app. Are you sure?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:title,nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = segmentedControl.selectedSegmentIndex;
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // send user to SMS
        NSLog(@"clicked the 'leave' button; tag: %d", actionSheet.tag);
    }
}

#pragma mark MGTwitterEngineDelegate methods

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
    twitterStatuses = [[NSArray alloc] initWithArray:statuses];
    //[self.tableView reloadData];
    NSLog(@"statusesReceived: %@", statuses);
}

- (void)requestSucceeded:(NSString *)connectionIdentifier {
    NSLog(@"requestSucceeded: %@", connectionIdentifier);
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
    NSLog(@"requestFailed: %@", connectionIdentifier);
}

@end

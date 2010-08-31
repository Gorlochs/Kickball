//
//  ProfileFriendsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/13/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Three20/Three20.h"
#import "ProfileFriendsViewController.h"
#import "FoursquareAPI.h"
#import "ProfileViewController.h"
#import "Utilities.h"

@implementation ProfileFriendsViewController

@synthesize userId;

- (void)viewDidLoad {
    self.hideRefresh = YES;
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
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
    // create dictionary of icons to help speed up the scrolling
    
//    userIcons = [[NSMutableDictionary alloc] initWithCapacity:1];
//    for (FSUser *user in friends) {
//        if (user && user.photo && user.userId) {
//            UIImage *img = [[Utilities sharedInstance] getCachedImage:user.photo];
//            [userIcons setObject:img forKey:user.userId];
//        }
//    }
    [theTableView reloadData];
    [self stopProgressBar];
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
    return [friends count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"icon-default.png"];   
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
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
	/*
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"icon-default.png"];   
    }
    */
    // Set up the cell...
    FSUser *user = (FSUser*)[friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.firstnameLastInitial;
    
    CGRect frame = CGRectMake(4,4,36,36);
    TTImageView *ttImage = [[[TTImageView alloc] initWithFrame:frame] autorelease];
    ttImage.urlPath = user.photo;
    ttImage.backgroundColor = [UIColor clearColor];
    ttImage.defaultImage = [UIImage imageNamed:@"icon-default.png"];
    ttImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
    [cell addSubview:ttImage];
    
    float sw=32/cell.imageView.image.size.width;
    float sh=32/cell.imageView.image.size.height;
    cell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 8.0; 
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self displayProperProfileView:((FSUser*)[friends objectAtIndex:indexPath.row]).userId];
}


- (void)dealloc {
    [userId release];
    [friends release];
    [userIcons release];
    [super dealloc];
}


@end


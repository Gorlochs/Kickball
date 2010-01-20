//
//  ProfileFriendsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 1/13/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileFriendsViewController.h"
#import "FoursquareAPI.h"
#import "ProfileViewController.h"
#import "Utilities.h"

@implementation ProfileFriendsViewController

@synthesize userId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startProgressBar:@"Retrieving friends..."];
    [[FoursquareAPI sharedInstance] getFriendsWithUserIdAndTarget:userId andTarget:self andAction:@selector(friendsResponseReceived:withResponseString:)];
}


- (void)friendsResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    NSLog(@"friends: %@", inString);
    friends = [FoursquareAPI friendUsersFromRequestResponseXML:inString];
    // create dictionary of icons to help speed up the scrolling
    
    userIcons = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (FSUser *user in friends) {
        if (user && user.photo && user.userId) {
            UIImage *img = [[Utilities sharedInstance] getCachedImage:user.photo];
            [userIcons setObject:img forKey:user.userId];
        }
    }
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
    }
    
    // Set up the cell...
    FSUser *user = (FSUser*)[friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.firstnameLastInitial;
    cell.imageView.image = [userIcons objectForKey:user.userId];
    
    float sw=32/cell.imageView.image.size.width;
    float sh=32/cell.imageView.image.size.height;
    cell.imageView.transform=CGAffineTransformMakeScale(sw,sh);
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 8.0; 
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ProfileViewController *profileController = [[ProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
    profileController.userId = ((FSUser*)[friends objectAtIndex:indexPath.row]).userId;
    [self.navigationController pushViewController:profileController animated:YES];
    [profileController release];
}


- (void)dealloc {
    [theTableView release];
    [userId release];
    [friends release];
    [super dealloc];
}


@end

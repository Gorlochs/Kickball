    //
//  KBUserTweetsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/20/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBUserTweetsViewController.h"
#import "KBTwitterRecentTweetsTableCell.h"
#import "KickballAPI.h"

@implementation KBUserTweetsViewController

@synthesize userDictionary;
@synthesize username;

- (void) viewDidLoad {
    pageType = KBPageTypeOther;
    [super viewDidLoad];
    
    cachingKey = [NSString stringWithString:username];
    
    if (self.userDictionary) {
        screenNameLabel.text = [self.userDictionary objectForKey:@"screen_name"];
        fullName.text = [self.userDictionary objectForKey:@"name"];
        
        CGRect frame = CGRectMake(11, 53, 49, 49);
        userProfileImage = [[TTImageView alloc] initWithFrame:frame];
        userProfileImage.backgroundColor = [UIColor clearColor];
        userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        userProfileImage.urlPath = [self.userDictionary objectForKey:@"profile_image_url"];
        [self.view addSubview:userProfileImage];
    }
}

- (void) showStatuses {
    [self executeQuery:0];
}

- (void) executeQuery:(int)pageNumber {
    if (self.userDictionary) {
        [twitterEngine getUserTimelineFor:[self.userDictionary objectForKey:@"screen_name"] sinceID:0 startingAtPage:pageNumber count:25];
    } else {
        [twitterEngine getUserTimelineFor:self.username sinceID:0 startingAtPage:pageNumber count:25];
    }
}

- (void)statusesReceived:(NSArray *)statuses {
    [super statusesReceived:statuses];
	
    // this is used when there is no userDictionary, which occurs when a user clicks a @screenname inside the body of a tweet
    NSArray *userStatuses = [statuses retain];
    if (userDictionary == nil && [userStatuses count] > 0) {
        screenNameLabel.text = [[[userStatuses objectAtIndex:0] objectForKey:@"user"] objectForKey:@"screen_name"];
        fullName.text = [[[userStatuses objectAtIndex:0] objectForKey:@"user"] objectForKey:@"name"];
        
        CGRect frame = CGRectMake(11, 53, 49, 49);
        userProfileImage = [[TTImageView alloc] initWithFrame:frame];
        userProfileImage.backgroundColor = [UIColor clearColor];
        userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        userProfileImage.urlPath = [[[userStatuses objectAtIndex:0] objectForKey:@"user"] objectForKey:@"profile_image_url"];
        [self.view addSubview:userProfileImage];
    }
	[userStatuses release];
}

- (void) refreshTable {
    [self showStatuses];
}

#pragma mark -
#pragma mark table stuff

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    KBTwitterRecentTweetsTableCell *cell = (KBTwitterRecentTweetsTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[KBTwitterRecentTweetsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell...
	//cell.textLabel.text = [[statuses objectAtIndex:indexPath.row] objectForKey:@"text"];
	KBTweet *tweet = [tweets objectAtIndex:indexPath.row];
	
	cell.tweetText.numberOfLines = 0;
	cell.tweetText.text = tweet.tweetText;
	cell.dateLabel.text = [[KickballAPI kickballApi] convertDateToTimeUnitString:tweet.createDate];
	
	CGSize maximumLabelSize = CGSizeMake(250, MAX_LABEL_HEIGHT);
	CGSize expectedLabelSize = [cell.tweetText.text sizeWithFont:cell.tweetText.font 
											   constrainedToSize:maximumLabelSize 
												   lineBreakMode:UILineBreakModeWordWrap]; 
	
	//adjust the label the the new height.
	CGRect newFrame = cell.tweetText.frame;
	newFrame.size.height = expectedLabelSize.height;
	cell.tweetText.frame = newFrame;
	
	CGRect dateFrame = cell.dateLabel.frame;
	dateFrame.origin = CGPointMake(20, expectedLabelSize.height + 10);
	cell.dateLabel.frame = dateFrame;
	
	return cell;
}

#pragma mark -
#pragma mark memory management

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
    [userDictionary release];
    [username release];
    [screenNameLabel release];
    [fullName release];
    [location release];
    [userProfileImage release];
    [super dealloc];
}


@end

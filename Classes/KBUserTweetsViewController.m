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
#import "KBCreateTweetViewController.h"

@implementation KBUserTweetsViewController

@synthesize userDictionary;
@synthesize username;

- (void) viewDidLoad {
    pageType = KBPageTypeOther;
    [super viewDidLoad];
	
	location.text = @"";
    
    cachingKey = [NSString stringWithString:username];
    
    screenNameLabel.text = @""; //a dictionary may not have been returned, such as when a user views protected tweets
    fullName.text = @"";
    if (self.userDictionary) {
        screenNameLabel.text = [self.userDictionary objectForKey:@"screen_name"];
        fullName.text = [self.userDictionary objectForKey:@"name"];
        if ([[self.userDictionary objectForKey:@"location"] isKindOfClass:[NSString class]]) {
            if (![[self.userDictionary objectForKey:@"location"] isEqualToString:@""]) {
                location.text = [self.userDictionary objectForKey:@"location"];
            } else {
                location.text = @"Not available";
            }
        }
		UIImageView *iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitIconBG.png"]];
		iconBgImage.frame = CGRectMake(14, 63, 37, 38);
		[self.view addSubview:iconBgImage];
        [iconBgImage release];
		
        CGRect frame = CGRectMake(16, 65, 33, 34);
        TTImageView *userProfileImage = [[TTImageView alloc] initWithFrame:frame];
        userProfileImage.backgroundColor = [UIColor clearColor];
        userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:3 topRight:3 bottomRight:3 bottomLeft:3] next:[TTContentStyle styleWithNext:nil]];
        userProfileImage.urlPath = [self.userDictionary objectForKey:@"profile_image_url"];
        [self.view addSubview:userProfileImage];
        [userProfileImage release];
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
        NSString *locationText = [[[userStatuses objectAtIndex:0] objectForKey:@"user"] objectForKey:@"location"];
        if ([locationText isKindOfClass:[NSString class]]) {
            if (![locationText isEqualToString:@""]) {
                location.text = locationText;
            }
        }
        CGRect frame = CGRectMake(9, 58, 49, 49);
        TTImageView *userProfileImage = [[TTImageView alloc] initWithFrame:frame];
        userProfileImage.backgroundColor = [UIColor clearColor];
        userProfileImage.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
        userProfileImage.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        userProfileImage.urlPath = [[[userStatuses objectAtIndex:0] objectForKey:@"user"] objectForKey:@"profile_image_url"];
        [self.view addSubview:userProfileImage];
        [userProfileImage release];
    }
	[userStatuses release];
    DLog(@"done with tweets view");
}

- (void) refreshTable {
    [self showStatuses];
}


- (void) sendDirectMessage {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
	tweetController.directMentionToScreenname = username;
	[self.navigationController pushViewController:tweetController animated:YES];
	[tweetController release];
}

- (void) sendTweet {
    KBCreateTweetViewController *tweetController = [[KBCreateTweetViewController alloc] initWithNibName:@"KBCreateTweetViewController" bundle:nil];
	tweetController.replyToScreenName = username;
	[self.navigationController pushViewController:tweetController animated:YES];
	[tweetController release];
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
	dateFrame.origin = CGPointMake(20, expectedLabelSize.height + 20);
	cell.dateLabel.frame = dateFrame;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        [cell setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];  
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
    [super dealloc];
}


@end

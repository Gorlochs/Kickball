    //
//  KBFacebookListViewController.m
//  Kickball
//
//  Created by scott bates on 6/10/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookListViewController.h"
#import "KBFacebookNewsCell.h"
#import "KBFacebookLoginView.h"
#import "KBFacebookPostDetailViewController.h"
#import "FBFacebookCreatePostViewController.h"
#import "FacebookProxy.h"
#import "GraphObject.h"
#import "KickballAPI.h"
#import "GraphAPI.h"

@interface KBFacebookStyleSheet : TTDefaultStyleSheet
@end

@implementation KBFacebookStyleSheet

- (TTStyle*)fbBlueText {
	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:12.0] color:[UIColor colorWithRed:76/255.0 green:127/255.0 blue:220/255.0 alpha:1.0]
					  minimumFontSize:12 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
						 shadowOffset:CGSizeMake(0, -1) next:nil];
}
- (TTStyle*)fbLargeBlueText {
	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14.0] color:[UIColor colorWithRed:76/255.0 green:127/255.0 blue:220/255.0 alpha:1.0]
					  minimumFontSize:12 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
						 shadowOffset:CGSizeMake(0, -1) next:nil];
}
- (TTStyle*)fbRedText {
	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12.0] color:[UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
					  minimumFontSize:12 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
						 shadowOffset:CGSizeMake(0, -1) next:nil];
}
- (TTStyle*)fbLargeRedText {
	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:14.0] color:[UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]
					  minimumFontSize:12 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
						 shadowOffset:CGSizeMake(0, -1) next:nil];
}
@end

@implementation KBFacebookListViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)startLoadingDefaults {
    // try to load up the managers for the various services
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    [FacebookProxy loadDefaults];
	[[FacebookProxy instance] storeProfilePic];
    [pool release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //_loginThread = [[NSThread alloc] initWithTarget:self selector:@selector(startLoadingDefaults) object:nil];
    //[_loginThread start];

	[TTStyleSheet setGlobalStyleSheet:[[[KBFacebookStyleSheet alloc] init] autorelease]];
	pageType = KBPageTypeFriends;
	pageNum = 1;
    pageViewType = KBPageViewTypeList;
    [super viewDidLoad];
	doingLogin = NO;
	newsFeed = nil;
	nextPageURL = [[NSString alloc] init];
	requeryWhenTableGetsToBottom = YES;
	//[FacebookProxy loadDefaults];
	if ([[FacebookProxy instance] isAuthorized]) {
		//[self startProgressBar:@"Retrieving your tweets..."];
		//[self showStatuses];
		//[self refreshMainFeed];
		[self startProgressBar:@"Retrieving news feed..."];
		[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
		if (![FacebookProxy instance].profilePic) {
			[NSThread detachNewThreadSelector:@selector(getLoggedInProfilePic) toTarget:[FacebookProxy instance] withObject:nil];
		}

	} else {
		[self showLoginView];
    }
	
	heightTester = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
	heightTester.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
	heightTester.font = [UIFont fontWithName:@"Helvetica" size:12.0];
	heightTester.backgroundColor = [UIColor clearColor];
}

-(void)refreshMainFeed{
	if (newsFeed) [newsFeed release];
	newsFeed = nil;
	requeryWhenTableGetsToBottom = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	//newsFeed = [graph newsFeed:@"me"];
	NSDictionary *feed = [graph newMeFeed];
	newsFeed = [[NSMutableArray alloc] initWithArray:[feed objectForKey:@"posts"]];
	[[FacebookProxy instance] cacheIncomingProfiles:[feed objectForKey:@"profiles"]];
	[[FacebookProxy instance] cacheIncomingProfiles:[feed objectForKey:@"albums"]];
	//[newsFeed retain];
	//[nextPageURL release];
	//nextPageURL = nil;
	//nextPageURL = graph._pagingNext;
	//[nextPageURL retain];
	[graph release];
	[theTableView reloadData];
	[self dataSourceDidFinishLoadingNewData];
	[pool release];

	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	//[self performSelectorOnMainThread:@selector(setTabImages) withObject:nil waitUntilDone:NO];
	//[self stopProgressBar];

}

-(void)concatenateMore:(NSString*)urlString{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *lastItem = [newsFeed lastObject];
	NSNumber *lastStamp = [lastItem objectForKey:@"created_time"];
	DLog(@"asking for more posts after: %@",lastStamp);
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	NSDictionary *moreFeed = [graph newMeFeed:lastStamp];
	NSMutableArray *moreNews = [[NSMutableArray alloc] initWithArray:[moreFeed objectForKey:@"posts"]];
	//[moreNews retain]; //startLoadingDefaults sometimes releases an autorelease pool while we use this object.  this will keep the object from getting released, and us from crashing
	[[FacebookProxy instance] cacheIncomingProfiles:[moreFeed objectForKey:@"profiles"]];
	[[FacebookProxy instance] cacheIncomingProfiles:[moreFeed objectForKey:@"albums"]];

	if (moreNews!=nil) {
		if ([moreNews count]==0) {
			requeryWhenTableGetsToBottom = NO;
		}
        if (!newsFeed) newsFeed = [[NSMutableArray alloc] init];
		[newsFeed addObjectsFromArray:moreNews];
		[theTableView reloadData];
	}
	[self dataSourceDidFinishLoadingNewData];
	[graph release];
	[moreNews release];
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
}

- (void) refreshTable {
	//[self startProgressBar:@"Retrieving news feed..."];
	[self refreshMainFeed];
}

-(void)delayedRefresh{
	[self performSelector:@selector(refreshTable) withObject:nil afterDelay:2.0f];
}

-(IBAction)createPost{
	FBFacebookCreatePostViewController *postController = [[FBFacebookCreatePostViewController alloc] initWithNibName:@"FBFacebookCreatePostViewController" bundle:nil];
    [postController setDelegate:self];
	[self.navigationController pushViewController:postController animated:YES];
	[postController release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (newsFeed!=nil) {
		return [newsFeed count];
	}
    return 0;
}

/*
-(BOOL)doesHavePhoto:(NSDictionary*)fbItem{
	NSDictionary *attachment = [fbItem objectForKey:@"attachment"];
	if (attachment) {
		NSArray *media  = [attachment objectForKey:@"media"];
		if (media) {
			if ([media isKindOfClass:[NSArray class]]) {
				if ([media count]>0) {
					NSDictionary *item = [media objectAtIndex:0];
					NSString *type = [item objectForKey:@"type"];
					if ([type isEqualToString:@"photo"]) {
						return YES;
					}else {
						return NO;
					}
				}else {
					return NO;
				}

			}else {
				return NO;
			}

		}else {
			return NO;
		}
	}else {
		return NO;
	}

}
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (newsFeed!=nil) {
		NSDictionary *fbItem = [newsFeed objectAtIndex:indexPath.row];
		NSString *bodyText = [[FacebookProxy instance] findSuitableText:fbItem];
		NSString *displayString = [NSString stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[[FacebookProxy instance] userNameFrom:[fbItem objectForKey:@"actor_id"]], bodyText];
		NSString *attribution = [fbItem objectForKey:@"attribution"];
		if ([attribution isKindOfClass:[NSString class]]) {
			if ([attribution isEqualToString:@"Kickball!"]) {
				displayString = [NSString stringWithFormat:@"%@ \n(via <span class=\"fbRedText\">%@</span>)",displayString, attribution];
			}
		}
		//DLog(@"display string: %@", displayString);
		
		heightTester.text = [TTStyledText textFromXHTML:displayString lineBreaks:YES URLs:NO twitterSpecific:NO];

		//heightTester.text = [TTStyledText textFromXHTML:[displayString stringByReplacingOccurrencesOfString:@"\n" withString:@""] lineBreaks:NO URLs:NO twitterSpecific:NO];
		[heightTester sizeToFit];
		int baseHeight = 38;
		BOOL withPhoto = [[FacebookProxy instance] doesHavePhoto:fbItem];
		if (withPhoto) {
			baseHeight+=138;
		}
		return heightTester.frame.size.height+baseHeight > 72 ? heightTester.frame.size.height+baseHeight : 72;
		//
		/*
		CGSize maximumLabelSize = CGSizeMake(250, 400);
		CGSize expectedLabelSize = [displayString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
											 constrainedToSize:maximumLabelSize 
												 lineBreakMode:UILineBreakModeWordWrap];
		int calculatedHeight = expectedLabelSize.height + 38;
		//if (calculatedHeight>50) {
			return calculatedHeight;
		//}
		 */
	}
	return 60;
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	KBFacebookNewsCell *cell = (KBFacebookNewsCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[KBFacebookNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    NSDictionary *fbItem = [newsFeed objectAtIndex:indexPath.row];
    NSString *bodyText = [[FacebookProxy instance] findSuitableText:fbItem];
    NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[[FacebookProxy instance] userNameFrom:[fbItem objectForKey:@"actor_id"]], bodyText];
	NSString *attribution = [fbItem objectForKey:@"attribution"];
	if ([attribution isKindOfClass:[NSString class]]) {
		if ([attribution isEqualToString:@"Kickball!"]) {
			displayString = [NSString stringWithFormat:@"%@ \n(via <span class=\"fbRedText\">%@</span>)",displayString, attribution];
		}
	}
    BOOL withPhoto = [[FacebookProxy instance] doesHavePhoto:fbItem];
	if (withPhoto) {
		cell.fbPictureUrl = [[FacebookProxy instance] imageUrlForPhoto:fbItem];
		cell.pictureAlbumId = [[FacebookProxy instance] albumIdForPhoto:fbItem];
		cell.pictureIndex = [[FacebookProxy instance] photoIndexWithinGallery:fbItem];
	}else {
		cell.fbPictureUrl = nil;
		cell.pictureAlbumId = nil;
	}
    
	/*
	NSString *type = [fbItem objectForKey:@"type"];
	if ([type isEqualToString:@"photo"]) {
		cell.fbPictureUrl = [fbItem objectForKey:@"picture"];
	}else if ([type isEqualToString:@"video"]) {
		cell.fbPictureUrl = [fbItem objectForKey:@"picture"];
	} else {
		cell.fbPictureUrl = nil;
	}

	//NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"name"], [fbItem propertyWithKey:@"message"]];
	 */
    cell.fbProfilePicUrl = [[FacebookProxy instance] profilePicUrlFrom:[fbItem objectForKey:@"actor_id"]];
	
   //cell.tweetText.text = [TTStyledText textFromXHTML:[displayString stringByReplacingOccurrencesOfString:@"\n" withString:@""] lineBreaks:NO URLs:NO twitterSpecific:NO];

	cell.tweetText.text = [TTStyledText textFromXHTML:displayString lineBreaks:YES URLs:NO twitterSpecific:NO];
	NSDictionary* commentDict = [fbItem objectForKey:@"comments"];
    if(commentDict){
		[cell setNumberOfComments:[(NSNumber*)[commentDict objectForKey:@"count"] intValue]];
	}else {
		[cell setNumberOfComments:0];
	}

	[cell setDateLabelWithText:[[KickballAPI kickballApi] convertDateToTimeUnitString:[NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[fbItem objectForKey:@"created_time"] intValue]]]]; //[[FacebookProxy fbDateFormatter] dateFromString:[fbItem objectForKey:@"created_time"]]]];
	[cell.tweetText sizeToFit];
	[cell.tweetText setNeedsDisplay];
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
		NSDictionary *fbItem = [newsFeed objectAtIndex:indexPath.row];
        KBFacebookPostDetailViewController *detailViewController = [[KBFacebookPostDetailViewController alloc] initWithNibName:@"KBFacebookPostDetailViewController" bundle:nil];
        [detailViewController populate:fbItem];
        [self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
    } else {
        //[self executeQuery:++pageNum];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [newsFeed count] - 1) {
        if (requeryWhenTableGetsToBottom) {
            //[self executeQuery:++pageNum];
			//[self startProgressBar:@"Retrieving more..."];

			[NSThread detachNewThreadSelector:@selector(concatenateMore:) toTarget:self withObject:nextPageURL];
			
        } else {
            DLog("********************* REACHED NO MORE RESULTS!!!!! **********************");
        }
	}
}

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
    [_loginThread release];
	[heightTester release];
	[nextPageURL release];
	[TTStyleSheet setGlobalStyleSheet:nil];
	[newsFeed release];
    [super dealloc];
}


@end

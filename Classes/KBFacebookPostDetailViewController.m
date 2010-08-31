    //
//  KBFacebookPostDetail.m
//  Kickball
//
//  Created by scott bates on 6/14/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookPostDetailViewController.h"
#import "GraphAPI.h"
#import "GraphObject.h"
#import "KickballAPI.h"
#import "TableSectionHeaderView.h"
#import "KBFacebookCommentCell.h"
#import "FacebookProxy.h"
#import "KBFacebookAddCommentViewController.h"

@implementation KBFacebookPostDetailViewController
@synthesize postView, commentView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		//self.contentView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
		iconBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellIconBorder.png"]];
		iconBgImage.frame = CGRectMake(8, 10, 38, 38);
		
        userIcon = [[TTImageView alloc] initWithFrame:CGRectMake(10, 12, 34, 34)];
        userIcon.backgroundColor = [UIColor clearColor];
        userIcon.defaultImage = [UIImage imageNamed:@"icon-default.png"];
        userIcon.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        
        dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        dateLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		dateLabel.textAlignment = UITextAlignmentLeft;
        
		fbPostText = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
		fbPostText.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		fbPostText.font = [UIFont fontWithName:@"Helvetica" size:14.0];
		fbPostText.backgroundColor = [UIColor clearColor];
		
		commentHightTester = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
		commentHightTester.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		commentHightTester.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		commentHightTester.backgroundColor = [UIColor clearColor];
		
		fbPictureUrl = nil;
		pictureAlbumId = nil;
		pictureThumb1 = [[TTImageView alloc] initWithFrame:CGRectMake(60, 50, 34, 34)];
        pictureThumb1.backgroundColor = [UIColor clearColor];
        pictureThumb1.defaultImage = [UIImage imageNamed:@"photoLoading.png"];
        pictureThumb1.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:4 topRight:4 bottomRight:4 bottomLeft:4] next:[TTContentStyle styleWithNext:nil]];
        pictureThumb1.contentMode = UIViewContentModeScaleAspectFit;
		pictureButt = [UIButton buttonWithType:UIButtonTypeCustom];
		[pictureButt setFrame:pictureThumb1.frame];
		[pictureButt retain];
		[pictureButt addTarget:self action:@selector(pressPhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
		[pictureButt setEnabled:NO];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.hideFooter = YES;
    pageType = KBPageTypeOther;
    requeryWhenTableGetsToBottom = NO;
    [super viewDidLoad];
	[self.postView addSubview:iconBgImage];
	[self.postView addSubview:userIcon];
	[self.postView addSubview:dateLabel];
	[self.postView addSubview:fbPostText];
	NSString *bodyText = [[FacebookProxy instance] findSuitableText:fbItem];
	// if there is a non-facebook url associated with the post, display the shortened url
	NSString *href = [[fbItem objectForKey:@"attachment"] objectForKey:@"href"];
	if (href != nil && [href rangeOfString:@"facebook"].location == NSNotFound) {
		NSString *shortHref = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://is.gd/api.php?longurl=%@", href]] encoding:NSASCIIStringEncoding error:nil];
		if(shortHref!=nil)
			bodyText = [NSString stringWithFormat:@"%@<br/>%@",bodyText, shortHref];
	}
	NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbLargeBlueText\">%@</span> %@",[[FacebookProxy instance] userNameFrom:[fbItem objectForKey:@"actor_id"]], bodyText];
	NSString *attribution = [fbItem objectForKey:@"attribution"];
	if ([attribution isKindOfClass:[NSString class]]) {
		if ([attribution isEqualToString:@"Kickball!"]) {
			displayString = [NSString stringWithFormat:@"%@ - via <span class=\"fbLargeRedText\">%@</span>",displayString, attribution];
		}
	}
	fbPostText.text = [TTStyledText textFromXHTML:[displayString stringByReplacingOccurrencesOfString:@"\n" withString:@""] lineBreaks:YES URLs:YES twitterSpecific:NO];
	NSDictionary *commentDict = [fbItem objectForKey:@"comments"];
	comments = [[NSArray alloc] initWithArray:(NSArray*)[commentDict objectForKey:@"comment_list"]];
	numComments = [(NSNumber*)[commentDict objectForKey:@"count"] intValue];
	dateLabel.text = [[KickballAPI kickballApi] convertDateToTimeUnitString:[NSDate dateWithTimeIntervalSince1970:[(NSNumber*)[fbItem objectForKey:@"created_time"] intValue]]]; //[[FacebookProxy fbDateFormatter] dateFromString:[fbItem objectForKey:@"created_time"]]]];
	[fbPostText sizeToFit];
	NSDictionary *likeInfo = [fbItem objectForKey:@"likes"];
	userLikes = [(NSNumber*)[likeInfo objectForKey:@"user_likes"] boolValue];
	if (userLikes) {
		[likeButton setImage:[UIImage imageNamed:@"btn-like01.png"] forState:UIControlStateNormal];
		[likeButton setImage:[UIImage imageNamed:@"btn-like02.png"] forState:UIControlStateHighlighted];
	}else {
		[likeButton setImage:[UIImage imageNamed:@"btn-like03.png"] forState:UIControlStateNormal];
		[likeButton setImage:[UIImage imageNamed:@"btn-like02.png"] forState:UIControlStateHighlighted];
	}

	CGRect postSize = fbPostText.frame;
	[fbPostText setNeedsDisplay];
	int frameHeight = postSize.size.height+30 > 70 ? postSize.size.height+30 : 70;
	BOOL withPhoto = [[FacebookProxy instance] doesHavePhoto:fbItem];
	if (withPhoto) {
		frameHeight+=140;
		fbPictureUrl = [[FacebookProxy instance] imageUrlForPhoto:fbItem];
		pictureAlbumId = [[FacebookProxy instance] albumIdForPhoto:fbItem];
		pictureThumb1.frame = CGRectMake(58, frameHeight-154, 130, 130);
		pictureButt.frame = pictureThumb1.frame;
		postView.frame = CGRectMake(0, 47, 320, frameHeight);
		commentView.frame = CGRectMake(0, frameHeight+47, 320, 46);
		theTableView.frame = CGRectMake(0, frameHeight+93, 320, 460-frameHeight-93);
		dateLabel.frame = CGRectMake(58, frameHeight-20, 200, 16);
		[self.postView addSubview:pictureThumb1];
		[self.postView addSubview:pictureButt];
		[pictureButt setEnabled:YES];
		[pictureThumb1 setUrlPath:fbPictureUrl];
	}else {
		fbPictureUrl = nil;
		pictureAlbumId = nil;
		postView.frame = CGRectMake(0, 47, 320, frameHeight);
		commentView.frame = CGRectMake(0, frameHeight+47, 320, 46);
		theTableView.frame = CGRectMake(0, frameHeight+93, 320, 460-frameHeight-93);
		dateLabel.frame = CGRectMake(58, frameHeight-20, 200, 16);
	}
	
	[userIcon setUrlPath:[[FacebookProxy instance] profilePicUrlFrom:[fbItem objectForKey:@"actor_id"]]];
	[theTableView reloadData];
	if (numComments> [comments count]) {
		[self startProgressBar:@"loading comments"];
		[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
	}
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
}

-(void)populate:(NSDictionary*)obj{
	fbItem = [obj retain];
}

- (void)handleTweetNotification:(NSNotification *)notification {
	DLog(@"handleTweetNotification: notification = %@", notification);
    NSMutableString *nObject = [[NSMutableString alloc] initWithString:[notification object]];
	[nObject replaceOccurrencesOfString:@":" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	[nObject replaceOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	[nObject replaceOccurrencesOfString:@"!" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	[nObject replaceOccurrencesOfString:@";" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	[nObject replaceOccurrencesOfString:@"," withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	[nObject replaceOccurrencesOfString:@"?" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];
	//[nObject replaceOccurrencesOfString:@"@" withString:@"#" options:NSLiteralSearch range:NSMakeRange(0, [nObject length])];

        [self openWebView:[notification object]];

    [nObject release];
}

-(void)loadPicUrl{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary* args = [NSDictionary dictionaryWithObject:@"picture" forKey:@"fields"];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	GraphObject *graphObj = [graph getObject:fbPictureUrl withArgs:args];
	//userIcon.urlPath = [fbItem propertyWithKey:@"picture"];
	NSString *staticUrl = [graphObj propertyWithKey:@"picture"];
	if (staticUrl!=nil) {
		[[FacebookProxy instance].pictureUrls setObject:staticUrl forKey:fbPictureUrl];
		[userIcon performSelectorOnMainThread:@selector(setUrlPath:) withObject:staticUrl waitUntilDone:YES];
		
	}
	[graph release];
	[pool release];
}

-(void)refreshMainFeed {
	
	requeryWhenTableGetsToBottom = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	NSArray* incomingComments = [graph commentFeedForPost:[fbItem objectForKey:@"post_id"]];//[graph getConnections:@"comments" forObject:[fbItem propertyWithKey:@"id"]];
	BOOL update = YES;
	if (incomingComments==nil) {
		update = NO;
	}
	if ([incomingComments count]==0) {
		update = NO;
	}
	if (update) {
		[comments release];
		comments = nil;
		comments = incomingComments;
		[comments retain];
		NSMutableArray *profileIds = [[NSMutableArray alloc] init];
		for (NSDictionary *comm in comments){
			[profileIds addObject:[comm objectForKey:@"fromid"]];
		}
		NSArray *incomingProfiles = [graph getProfileObjects:profileIds];
		[[FacebookProxy instance] cacheIncomingProfiles:incomingProfiles];
		[profileIds release];
		[theTableView reloadData];
	}
	
	//[nextPageURL release];
	//nextPageURL = nil;
	//nextPageURL = graph._pagingNext;
	//[nextPageURL retain];
	[graph release];	
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(dataSourceDidFinishLoadingNewData) withObject:nil waitUntilDone:NO];
	
}

-(void)concatenateMore:(NSString*)urlString{
	if (urlString==nil) {
		[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
		return;
	}
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	NSArray *moreNews = [graph nextPage:urlString];
	if (moreNews!=nil) {
		if ([moreNews count]==0) {
			requeryWhenTableGetsToBottom = NO;
		}
		[nextPageURL release];
		nextPageURL = nil;
		nextPageURL = graph._pagingNext;
		[nextPageURL retain];
		NSMutableArray * fullBoat = [[NSMutableArray alloc] init];
		[fullBoat addObjectsFromArray:comments];
		[fullBoat addObjectsFromArray:moreNews];
		[comments release];
		comments = nil;
		comments = fullBoat;
		[comments retain];
		[fullBoat release];
		fullBoat = nil;
		[theTableView reloadData];
	}
	[self dataSourceDidFinishLoadingNewData];
	[graph release];
	[pool release];
	
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
}


- (void) refreshTable {
	//[self startProgressBar:@"Retrieving news feed..."];
	[self refreshMainFeed];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			if (comments!=nil) {
				return [comments count];
			}
			return 0;
		case 1:
			//return the number of comments
			return 0;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *comment;
	switch (indexPath.section) {
		case 0:
			comment = [comments objectAtIndex:indexPath.row];
			NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[[FacebookProxy instance] userNameFrom:[comment objectForKey:@"fromid"]], [comment objectForKey:@"text"]];
			commentHightTester.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO twitterSpecific:NO];
			[commentHightTester sizeToFit];
			return commentHightTester.frame.size.height+30 > 58 ? commentHightTester.frame.size.height+30 : 58;
		case 1:
			//calculate height of comment cell
			return 60;
		default:
			return 44;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	TableSectionHeaderView *sectionHeaderView;
	sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
	//numComments = [comments count];
	if (numComments) {
		sectionHeaderView.leftHeaderLabel.text = numComments > 1 ? [NSString stringWithFormat:@"%i Comments",numComments] : [NSString stringWithFormat:@"%i Comment",numComments];
	}else{
		sectionHeaderView.leftHeaderLabel.text = @"No Comments";
	}
	sectionHeaderView.rightHeaderLabel.text = @"";
	return sectionHeaderView;
	
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";	
	KBFacebookCommentCell *cell = (KBFacebookCommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[KBFacebookCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	NSDictionary *comment = [comments objectAtIndex:indexPath.row];
	NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[[FacebookProxy instance] userNameFrom:[comment objectForKey:@"fromid"]], [comment objectForKey:@"text"]];
	cell.fbPictureUrl = [[FacebookProxy instance] profilePicUrlFrom:[comment objectForKey:@"fromid"]];
	cell.commentText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO twitterSpecific:NO];
	[cell.commentText sizeToFit];
	[cell.commentText setNeedsDisplay];
	return cell;
	
    
}
/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [comments count] - 1) {
        if (requeryWhenTableGetsToBottom) {
            //[self executeQuery:++pageNum];
			[self startProgressBar:@"Retrieving more..."];
			
			[NSThread detachNewThreadSelector:@selector(concatenateMore:) toTarget:self withObject:nextPageURL];
			
        } else {
            DLog("********************* REACHED NO MORE RESULTS!!!!! **********************");
        }
	}
}
*/

-(IBAction)pressLike{
	[NSThread detachNewThreadSelector:@selector(pressLikeThreaded) toTarget:self withObject:nil];

	//GraphAPI *graph = [[[FacebookProxy instance] newGraph] autorelease];
	//[NSThread detachNewThreadSelector:@selector(likeObject:) toTarget:graph withObject:[fbItem propertyWithKey:@"id"]];
	//GraphObject *result = [[[FacebookProxy instance] newGraph] likeObject:[fbItem propertyWithKey:@"id"]]
	//[fbItem propertyWithKey:@"id"]
}

-(void)pressLikeThreaded{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	userLikes = !userLikes;
	GraphAPI *graph = [[[FacebookProxy instance] newGraph] autorelease];
	if (userLikes) {
		[graph likeObject:[fbItem objectForKey:@"post_id"]];
		[likeButton setImage:[UIImage imageNamed:@"btn-like01.png"] forState:UIControlStateNormal];
		[likeButton setImage:[UIImage imageNamed:@"btn-like02.png"] forState:UIControlStateHighlighted];
	}else {
		[graph unlikeObject:[fbItem objectForKey:@"post_id"]];
		[likeButton setImage:[UIImage imageNamed:@"btn-like03.png"] forState:UIControlStateNormal];
		[likeButton setImage:[UIImage imageNamed:@"btn-like02.png"] forState:UIControlStateHighlighted];
	}
	[(NSMutableDictionary*)[fbItem objectForKey:@"likes"] setObject:[NSNumber numberWithBool:userLikes] forKey:@"user_likes"];

	[pool release];
	
}

-(void)pressPhotoAlbum{
	[self displayAlbum:pictureAlbumId];
}
-(IBAction)touchComment{
	KBFacebookAddCommentViewController* commentController = [[KBFacebookAddCommentViewController alloc] initWithNibName:@"KBFacebookAddComment" bundle:nil];
    commentController.fbId = [fbItem objectForKey:@"post_id"];
	commentController.parentView = self;
	commentController.isComment = YES;
    [self presentModalViewController:commentController animated:YES];
	[commentController release];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:NO];
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[nextPageURL release];
	[comments release];
	[commentHightTester release];
	[iconBgImage release];
	[userIcon release];
	[dateLabel release];
	[fbPostText release];
	[fbItem release];
	[postView release];
	[commentView release];
    [super dealloc];
}


@end

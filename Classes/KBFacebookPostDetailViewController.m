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
        userIcon.defaultImage = [UIImage imageNamed:@"blank_boy.png"];
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
		fbPostText.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		fbPostText.backgroundColor = [UIColor clearColor];
		
		commentHightTester = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
		commentHightTester.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
		commentHightTester.font = [UIFont fontWithName:@"Helvetica" size:12.0];
		commentHightTester.backgroundColor = [UIColor clearColor];
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.hideFooter = YES;
    pageType = KBPageTypeOther;
    
    [super viewDidLoad];
	[self.postView addSubview:iconBgImage];
	[self.postView addSubview:userIcon];
	[self.postView addSubview:dateLabel];
	[self.postView addSubview:fbPostText];

	NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"name"], [fbItem propertyWithKey:@"message"]];
	fbPictureUrl = [(NSDictionary*)[fbItem propertyWithKey:@"from"] objectForKey:@"id"];
	fbPostText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
	comments = (NSArray*)[(NSDictionary*)[fbItem propertyWithKey:@"comments"] objectForKey:@"data"];
	numComments = [comments count];
	dateLabel.text = [[KickballAPI kickballApi] convertDateToTimeUnitString:[[FacebookProxy fbDateFormatter] dateFromString:[fbItem propertyWithKey:@"created_time"]]];
	[fbPostText sizeToFit];
	CGRect postSize = fbPostText.frame;
	[fbPostText setNeedsDisplay];
	int frameHeight = postSize.size.height+30 > 70 ? postSize.size.height+30 : 70;
	postView.frame = CGRectMake(0, 47, 320, frameHeight);
	commentView.frame = CGRectMake(0, frameHeight+47, 320, 46);
	theTableView.frame = CGRectMake(0, frameHeight+93, 320, 460-frameHeight-93);
	dateLabel.frame = CGRectMake(58, frameHeight-20, 200, 16);
	
	NSString *cachedUrl = [[FacebookProxy instance].pictureUrls objectForKey:fbPictureUrl];
	if (cachedUrl!=nil) {
		[userIcon setUrlPath:cachedUrl];
	}else {
		[NSThread detachNewThreadSelector:@selector(loadPicUrl) toTarget:self withObject:nil];
	}
	[theTableView reloadData];
}

-(void)populate:(GraphObject*)obj{
	fbItem = [obj retain];
}

-(void)loadPicUrl{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary* args = [NSDictionary dictionaryWithObject:@"picture" forKey:@"fields"];
	GraphObject *fbItem = [[[FacebookProxy instance] newGraph] getObject:fbPictureUrl withArgs:args];
	//userIcon.urlPath = [fbItem propertyWithKey:@"picture"];
	NSString *staticUrl = [fbItem propertyWithKey:@"picture"];
	if (staticUrl!=nil) {
		[[FacebookProxy instance].pictureUrls setObject:staticUrl forKey:fbPictureUrl];
		[userIcon performSelectorOnMainThread:@selector(setUrlPath:) withObject:staticUrl waitUntilDone:YES];
		
	}
	[pool release];
}

-(void)refreshMainFeed{
	[comments release];
	comments = nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	comments = [graph getConnections:@"comments" forObject:[fbItem propertyWithKey:@"id"]];
	[comments retain];
	[theTableView reloadData];
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	[self dataSourceDidFinishLoadingNewData];
	
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
			NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"name"], [comment objectForKey:@"message"]];
			commentHightTester.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
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
	numComments = [comments count];
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
	NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"name"], [comment objectForKey:@"message"]];
	cell.fbPictureUrl = [(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"id"];
	cell.commentText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
	[cell.commentText sizeToFit];
	[cell.commentText setNeedsDisplay];
	return cell;
	
    
}

-(IBAction)pressLike{
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[NSThread detachNewThreadSelector:@selector(likeObject:) toTarget:graph withObject:[fbItem propertyWithKey:@"id"]];
	//GraphObject *result = [[[FacebookProxy instance] newGraph] likeObject:[fbItem propertyWithKey:@"id"]]
	//[fbItem propertyWithKey:@"id"]
}
-(IBAction)touchComment{
	KBFacebookAddCommentViewController* commentController = [[KBFacebookAddCommentViewController alloc] initWithNibName:@"KBFacebookAddComment" bundle:nil];
    commentController.fbId = [fbItem propertyWithKey:@"id"];
	commentController.parentView = self;
	commentController.isComment = YES;
    [self presentModalViewController:commentController animated:YES];
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

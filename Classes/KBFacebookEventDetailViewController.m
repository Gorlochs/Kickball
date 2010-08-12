//
//  KBFacebookEventDetailViewController.m
//  Kickball
//
//  Created by scott bates on 6/17/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFacebookEventDetailViewController.h"
#import "TableSectionHeaderView.h"
#import "KBFacebookCommentCell.h"
#import "FacebookProxy.h"
#import "GraphAPI.h"
#import "GraphObject.h"
#import "KBFacebookAddCommentViewController.h"

@implementation KBFacebookEventDetailViewController

- (void)viewDidLoad {
	self.hideFooter = YES;
    pageType = KBPageTypeOther;

    [super viewDidLoad];
	nextPageURL = [[NSString alloc] init];
	requeryWhenTableGetsToBottom = YES;

	eventHost.text = [Utilities safeString:[event objectForKey:@"host"]];
	eventName.text = [Utilities safeString:[event objectForKey:@"name"]];
	eventLocation.text = [Utilities safeString:[event objectForKey:@"location"]];
	NSDate *fbEventDate = [NSDate dateWithTimeIntervalSince1970:[(NSString*)[event objectForKey:@"start_time"] intValue]];
	[fbEventDate addTimeInterval:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
	
	eventTime.text = [[FacebookProxy fbEventCellTimeFormatter] stringFromDate:fbEventDate];//@"6:30p";//[event objectForKey:];
	eventMonth.text = [[[FacebookProxy fbEventDetailMonthFormatter] stringFromDate:fbEventDate] uppercaseString];//@"SEP"; //[event objectForKey:@"24"];
	eventDay.text = [[FacebookProxy fbEventDetailDateFormatter] stringFromDate:fbEventDate];//@"24"; //[event objectForKey:];
	detailText.font = [UIFont systemFontOfSize:14.0];
	detailText.text = [Utilities safeString:[event objectForKey:@"description"]];
	NSString *rsvp = [event objectForKey:@"rsvp_status"];
	[attendingButt setSelected:NO];
	[notAttendingButt setSelected:NO];
	[attendingButt setEnabled:YES];
	[notAttendingButt setEnabled:YES];
	if ([rsvp isEqualToString:@"attending"]) {
		[attendingButt setSelected:YES];
		//[attendingButt setEnabled:NO];
	}else if([rsvp isEqualToString:@"declined"]) {
		[notAttendingButt setSelected:YES];
		//[notAttendingButt setEnabled:NO];
	}
	comments = nil;
	commentHightTester = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(58, 10, 250, 70)];
	commentHightTester.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
	commentHightTester.font = [UIFont fontWithName:@"Helvetica" size:12.0];
	commentHightTester.backgroundColor = [UIColor clearColor];
	
	[NSThread detachNewThreadSelector:@selector(refreshMainFeed) toTarget:self withObject:nil];
}

-(void)populate:(NSDictionary*)ev{
	event = [ev retain];
}

-(void)refreshMainFeed{
	
	[comments release];
	comments = nil;
	requeryWhenTableGetsToBottom = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	NSDictionary *feed = [graph eventFeed:[event objectForKey:@"eid"]];
	comments = [[NSMutableArray alloc] initWithArray:[feed objectForKey:@"posts"]];
	[[FacebookProxy instance] cacheIncomingProfiles:[feed objectForKey:@"profiles"]];
	[[FacebookProxy instance] cacheIncomingProfiles:[feed objectForKey:@"albums"]];
	[graph release];
	[theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];//[theTableView reloadData];
	[self dataSourceDidFinishLoadingNewData];
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
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
	}	[self dataSourceDidFinishLoadingNewData];
	[graph release];
	[pool release];
	
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];

}


- (void) refreshTable {
	//[self startProgressBar:@"Retrieving news feed..."];
	[self refreshMainFeed];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 2;
		case 1:
			//return the number of comments
			if (comments!=nil) {
				return [comments count];
			}
			return 0;
		default:
			return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *comment;
	switch (indexPath.section) {
		case 0:
			if (indexPath.row==0) {
				//calculate hight for detail cell
				return 100;
			}else {
				return 46;
			}
		case 1:
			//calculate height of comment cell
			comment = [comments objectAtIndex:indexPath.row];
			NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"name"], [comment objectForKey:@"message"]];
			commentHightTester.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
			[commentHightTester sizeToFit];
			return commentHightTester.frame.size.height+30 > 58 ? commentHightTester.frame.size.height+30 : 58;
		default:
			return 44;
	}
	
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	TableSectionHeaderView *sectionHeaderView;
	switch (section) {
		case 0:
			return nil;
		case 1:
			//if (eventsFeed!=nil) {
			//	NSDictionary *sectionDict = [eventsFeed objectAtIndex:section];
			//	if (sectionDict!=nil) {
			//		NSString *headerString = [sectionDict objectForKey:@"headerString"];
			//		if (headerString!=nil) {
						sectionHeaderView = [[[TableSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
			int numComments = [comments count];
			if (numComments) {
				sectionHeaderView.leftHeaderLabel.text = numComments > 1 ? [NSString stringWithFormat:@"%i Comments",numComments] : [NSString stringWithFormat:@"%i Comment",numComments];
			}else{
				sectionHeaderView.leftHeaderLabel.text = @"No Comments";
			}
						sectionHeaderView.leftHeaderLabel.text = @"Comments";
						sectionHeaderView.rightHeaderLabel.text = @"";
						return sectionHeaderView;
			//		}else {
			//			return nil;
			//		}
			//		
			//	}else {
			//		return nil;
			//	}
			//}
		default:
			return nil;
	}
		
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	KBFacebookCommentCell *cell;
	switch (indexPath.section) {
		case 0:
			if (indexPath.row==0) {
				//calculate hight for detail cell
				return detailCell;
			}else {
				return actionCell;
			}
		case 1:
			
			 cell = (KBFacebookCommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [[[KBFacebookCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			}
			NSDictionary *comment = [comments objectAtIndex:indexPath.row];
			NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[[FacebookProxy instance] userNameFrom:[comment objectForKey:@"actor_id"]], [comment objectForKey:@"message"]];
			cell.fbPictureUrl = [[FacebookProxy instance] profilePicUrlFrom:[comment objectForKey:@"actor_id"]];// [(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"id"];
			cell.commentText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
			[cell.commentText sizeToFit];
			[cell.commentText setNeedsDisplay];
			return cell;
		default:
			return nil;
	}
	
	
    
}

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


-(IBAction)pressAttending{
	[NSThread detachNewThreadSelector:@selector(threadedAttending) toTarget:self withObject:nil];

	//GraphAPI *graph = [[[FacebookProxy instance] newGraph] autorelease];
	//[NSThread detachNewThreadSelector:@selector(attendObject:) toTarget:graph withObject:[event objectForKey:@"eid"]];
	[attendingButt setSelected:YES];
	[notAttendingButt setSelected:NO];
	[event objectForKey:@"rsvp_status"];
	[event setValue:@"attending" forKey:@"rsvp_status"];
}
-(IBAction)pressNotAttending{
	[NSThread detachNewThreadSelector:@selector(threadedNotAttending) toTarget:self withObject:nil];

	//GraphAPI *graph = [[[FacebookProxy instance] newGraph] autorelease];
	//[NSThread detachNewThreadSelector:@selector(declineObject:) toTarget:graph withObject:[event objectForKey:@"eid"]];
	[attendingButt setSelected:NO];
	[notAttendingButt setSelected:YES];
	[event setValue:@"declined" forKey:@"rsvp_status"];

}

-(void)threadedAttending{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[[FacebookProxy instance] newGraph] autorelease];
	[graph attendObject:[event objectForKey:@"eid"]];
	[pool release];
}

-(void)threadedNotAttending{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	GraphAPI *graph = [[[FacebookProxy instance] newGraph] autorelease];
	[graph declineObject:[event objectForKey:@"eid"]];
	[pool release];
}

-(IBAction)touchComment{
	KBFacebookAddCommentViewController* commentController = [[KBFacebookAddCommentViewController alloc] initWithNibName:@"KBFacebookAddComment" bundle:nil];
    commentController.fbId = [event objectForKey:@"eid"];
	commentController.parentView = self;
	commentController.isComment = NO;
    [self presentModalViewController:commentController animated:YES];
	[commentController release];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:NO];
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
	[commentHightTester release];
	[nextPageURL release];
	[comments release];
	[event release];
    [super dealloc];
}


@end

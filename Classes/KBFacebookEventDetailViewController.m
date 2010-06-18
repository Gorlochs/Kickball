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
#import "GraphObject.h"
#import "KBFacebookAddCommentViewController.h"

@implementation KBFacebookEventDetailViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.hideFooter = YES;
    pageType = KBPageTypeOther;
    [super viewDidLoad];
	NSString *content = nil;
	content = [event objectForKey:@"host"];
	eventHost.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	content = [event objectForKey:@"name"];
	eventName.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	content = [event objectForKey:@"location"];
	eventLocation.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
	NSDate *fbEventDate = [NSDate dateWithTimeIntervalSince1970:[(NSString*)[event objectForKey:@"start_time"] intValue]];
	[fbEventDate addTimeInterval:[[NSTimeZone defaultTimeZone] secondsFromGMT]];
	
	eventTime.text = [[FacebookProxy fbEventCellTimeFormatter] stringFromDate:fbEventDate];//@"6:30p";//[event objectForKey:];
	eventMonth.text = [[[FacebookProxy fbEventDetailMonthFormatter] stringFromDate:fbEventDate] uppercaseString];//@"SEP"; //[event objectForKey:@"24"];
	eventDay.text = [[FacebookProxy fbEventDetailDateFormatter] stringFromDate:fbEventDate];//@"24"; //[event objectForKey:];
	content = [event objectForKey:@"description"];
	detailText.font = [UIFont systemFontOfSize:14.0];
	detailText.text = ![content isKindOfClass:[NSNull class]] ? content : @"";
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


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)populate:(NSDictionary*)ev{
	event = [ev retain];
}

-(void)refreshMainFeed{
	[comments release];
	comments = nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *method = [NSString stringWithFormat:@"%@/feed",[event objectForKey:@"eid"]];
	GraphObject* response = [[[FacebookProxy instance] newGraph] getObject:method];
	comments = [response propertyWithKey:@"data"];
	[comments retain];
	[theTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];//[theTableView reloadData];
	// = [[FacebookProxy instance] refreshEvents];
	//GraphObject *baseObj = [baseEventResult objectAtIndex:0];
	//comments = [[FacebookProxy instance] refreshEvents];
	[pool release];
	[self performSelectorOnMainThread:@selector(stopProgressBar) withObject:nil waitUntilDone:NO];
	[self dataSourceDidFinishLoadingNewData];
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
			NSString *displayString = [NSString	 stringWithFormat:@"<span class=\"fbBlueText\">%@</span> %@",[(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"name"], [comment objectForKey:@"message"]];
			cell.fbPictureUrl = [(NSDictionary*)[comment objectForKey:@"from"] objectForKey:@"id"];
			cell.commentText.text = [TTStyledText textFromXHTML:displayString lineBreaks:NO URLs:NO];
			[cell.commentText sizeToFit];
			[cell.commentText setNeedsDisplay];
			return cell;
		default:
			return nil;
	}
	
	
    
}

-(IBAction)pressAttending{
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[NSThread detachNewThreadSelector:@selector(attendObject:) toTarget:graph withObject:[event objectForKey:@"eid"]];
	[attendingButt setSelected:YES];
	[notAttendingButt setSelected:NO];
	[event objectForKey:@"rsvp_status"];
	[event setValue:@"attending" forKey:@"rsvp_status"];
}
-(IBAction)pressNotAttending{
	GraphAPI *graph = [[FacebookProxy instance] newGraph];
	[NSThread detachNewThreadSelector:@selector(declineObject:) toTarget:graph withObject:[event objectForKey:@"eid"]];
	[attendingButt setSelected:NO];
	[notAttendingButt setSelected:YES];
	[event setValue:@"declined" forKey:@"rsvp_status"];

}
-(IBAction)touchComment{
	KBFacebookAddCommentViewController* commentController = [[KBFacebookAddCommentViewController alloc] initWithNibName:@"KBFacebookAddComment" bundle:nil];
    commentController.fbId = [event objectForKey:@"eid"];
	commentController.parentView = self;
	commentController.isComment = NO;
    [self presentModalViewController:commentController animated:YES];
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
	[comments release];
	[event release];
    [super dealloc];
}


@end

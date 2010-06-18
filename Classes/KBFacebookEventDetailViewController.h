//
//  KBFacebookEventDetailViewController.h
//  Kickball
//
//  Created by scott bates on 6/17/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"
#import "Three20/Three20.h"


@interface KBFacebookEventDetailViewController : KBFacebookViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	IBOutlet UILabel *eventHost;
	IBOutlet UILabel *eventName;
	IBOutlet UILabel *eventLocation;
	IBOutlet UILabel *eventMonth;
	IBOutlet UILabel *eventDay;
	IBOutlet UILabel *eventTime;
	IBOutlet UITableViewCell *detailCell;
	IBOutlet UITableViewCell *actionCell;
	IBOutlet UITextView *detailText;
	IBOutlet UIButton *attendingButt;
	IBOutlet UIButton *notAttendingButt;
	NSDictionary *event;
	NSArray *comments;
	
	TTStyledTextLabel *commentHightTester;

}

-(IBAction)pressAttending;
-(IBAction)pressNotAttending;
-(IBAction)touchComment;
-(void)populate:(NSDictionary*)ev;
@end

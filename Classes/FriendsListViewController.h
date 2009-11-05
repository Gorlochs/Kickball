//
//  FriendsListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsMapViewController.h"FriendsMapViewController

@interface FriendsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
	NSArray * checkins;
	NSMutableArray * recentCheckins;
	NSMutableArray * olderCheckins;
}

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) NSMutableArray * recentCheckins;
@property (nonatomic, retain) NSMutableArray * olderCheckins;
@property (nonatomic, retain) UITableView *theTableView;

- (IBAction) checkin;
- (IBAction) flipToMap;
- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

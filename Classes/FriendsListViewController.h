//
//  FriendsListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
	NSArray * checkins;
}

- (IBAction) checkin;

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) UITableView *theTableView;

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;

@end

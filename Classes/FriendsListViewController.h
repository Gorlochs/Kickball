//
//  FriendsListViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 10/25/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsMapViewController.h"
#import "LoginViewModalController.h"
#import "InstructionView.h"
#import "FriendsMapViewController.h"


@interface FriendsListViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    IBOutlet UIButton *mapButton;
	NSArray * checkins;
	NSMutableArray * recentCheckins;
	NSMutableArray * todayCheckins;
	NSMutableArray * yesterdayCheckins;
    
    IBOutlet InstructionView *instructionView;
    IBOutlet UITableViewCell *footerViewCell;
    
    NSMutableDictionary *userIcons;
}

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) NSMutableArray * recentCheckins;
@property (nonatomic, retain) NSMutableArray * todayCheckins;
@property (nonatomic, retain) NSMutableArray * yesterdayCheckins;
@property (nonatomic, retain) UITableView *theTableView;

- (IBAction) checkin;
- (IBAction) flipToMap;
- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) doInitialDisplay;
- (IBAction) addFriend;
- (IBAction) refresh;

@end

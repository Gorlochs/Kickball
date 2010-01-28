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
#import "FriendsListTableCell.h"


@interface FriendsListViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *theTableView;
    IBOutlet UIButton *mapButton;
	NSArray * checkins;
	NSMutableArray * recentCheckins;
	NSMutableArray * todayCheckins;
	NSMutableArray * yesterdayCheckins;
    
    IBOutlet UIView *noNetworkView;
    IBOutlet InstructionView *instructionView;
    IBOutlet UITableViewCell *footerViewCell;
    IBOutlet UITableViewCell *moreCell;
    
    NSMutableDictionary *userIcons;
    
    int welcomePageNum;
    IBOutlet UIButton *nextWelcomeImage;
    IBOutlet UIButton *previousWelcomeImage;
    IBOutlet UIImageView *welcomeImage;
    
    BOOL hasViewedInstructions;
    BOOL isDisplayingMore;
}

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) NSMutableArray * recentCheckins;
@property (nonatomic, retain) NSMutableArray * todayCheckins;
@property (nonatomic, retain) NSMutableArray * yesterdayCheckins;
@property (nonatomic, retain) UITableView *theTableView;

- (IBAction) flipToMap;
- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) doInitialDisplay;
- (IBAction) addFriend;
- (IBAction) refresh;
- (IBAction) viewNextWelcomeImage;
- (IBAction) viewPreviousWelcomeImage;
- (IBAction) displayOlderCheckins;

@end

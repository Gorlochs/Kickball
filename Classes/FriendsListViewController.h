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
#import "AbstractPushNotificationViewController.h"
#import "KBTwitterManagerDelegate.h"
@class KBTwitterManager;

@interface FriendsListViewController : AbstractPushNotificationViewController <UITableViewDelegate, UITableViewDataSource, KBTwitterManagerDelegate> {
    IBOutlet UIButton *mapButton;
	NSArray * checkins;
	NSMutableArray * recentCheckins;
	NSMutableArray * todayCheckins;
	NSMutableArray * yesterdayCheckins;
	NSMutableArray * nonCityRecentCheckins;
	NSMutableArray * nonCityTodayCheckins;
	NSMutableArray * nonCityYesterdayCheckins;
    
    IBOutlet UIView *noNetworkView;
    IBOutlet InstructionView *instructionView;
    IBOutlet UITableViewCell *footerViewCell;
    //IBOutlet UITableViewCell *shoutCell;
    
    int welcomePageNum;
    IBOutlet UIButton *nextWelcomeImage;
    IBOutlet UIButton *previousWelcomeImage;
    IBOutlet UIImageView *welcomeImage;
    
    BOOL hasViewedInstructions;
    
    IBOutlet UIImageView *splashView;
    IBOutlet UIImageView *fadeOutImage;
    
    NSCalendar *gregorian;
//    UIImageView *mayorImageView;
    
    // shout related stuff
    IBOutlet UIView *shoutView;
    BOOL isTwitterOn;
    BOOL isFacebookOn;
    BOOL isFoursquareOn;
    IBOutlet UIButton *twitterButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *foursquareButton;
    IBOutlet UITextField *shoutText;
    int actionCount;
    KBTwitterManager *twitterManager;
	
	BOOL didPingUpdateRun;
	BOOL didInitialDisplay;
}

@property (nonatomic, assign) NSArray * checkins;
@property (nonatomic, retain) NSMutableArray * recentCheckins;
@property (nonatomic, retain) NSMutableArray * todayCheckins;
@property (nonatomic, retain) NSMutableArray * yesterdayCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityRecentCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityTodayCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityYesterdayCheckins;

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) doInitialDisplay;
- (IBAction) addFriend;
- (void) setupSplashAnimation;
- (void) instaCheckin:(NSNotification *)inNotification;

- (IBAction) displayShoutView;
- (IBAction) removeShoutView;
- (IBAction) toggleTwitter;
- (IBAction) toggleFacebook;
- (IBAction) toggleFoursquare;
-(void)updateFoursquareButton;
-(void)updateFacebookButton;
-(void)updateTwitterButton;
-(void)reloadCheckinTable;

@end

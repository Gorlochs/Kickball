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
}

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) NSMutableArray * recentCheckins;
@property (nonatomic, retain) NSMutableArray * todayCheckins;
@property (nonatomic, retain) NSMutableArray * yesterdayCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityRecentCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityTodayCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityYesterdayCheckins;

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) doInitialDisplay;
- (IBAction) addFriend;
- (IBAction) viewNextWelcomeImage;
- (IBAction) viewPreviousWelcomeImage;
//- (IBAction) displayOlderCheckins;
- (void) setupSplashAnimation;
- (void) instaCheckin:(NSNotification *)inNotification;
- (void) setUserIconViewCustom:(FSUser*)user;
//- (IBAction) displayTwitterXAuthLogin;
//- (void) showSplash;

- (IBAction) displayShoutView;
- (IBAction) removeShoutView;
- (IBAction) toggleTwitter;
- (IBAction) toggleFacebook;
- (IBAction) toggleFoursquare;
-(void)updateFoursquareButton;
-(void)updateFacebookButton;
-(void)updateTwitterButton;

@end

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
#import "KBFoursquareViewController.h"


@interface FriendsListViewController : KBFoursquareViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIButton *mapButton;
	NSArray * checkins;
	NSMutableArray * recentCheckins;
	NSMutableArray * todayCheckins;
	NSMutableArray * yesterdayCheckins;
	NSMutableArray * nonCityCheckins;
    
    IBOutlet UIView *noNetworkView;
    IBOutlet InstructionView *instructionView;
    IBOutlet UITableViewCell *footerViewCell;
    IBOutlet UITableViewCell *moreCell;
    
    int welcomePageNum;
    IBOutlet UIButton *nextWelcomeImage;
    IBOutlet UIButton *previousWelcomeImage;
    IBOutlet UIImageView *welcomeImage;
    
    BOOL hasViewedInstructions;
    BOOL isDisplayingMore;
    
    IBOutlet UIImageView *splashView;
    IBOutlet UIImageView *fadeOutImage;
    
    NSCalendar *gregorian;
//    UIImageView *mayorImageView;
}

@property (nonatomic, retain) NSArray * checkins;
@property (nonatomic, retain) NSMutableArray * recentCheckins;
@property (nonatomic, retain) NSMutableArray * todayCheckins;
@property (nonatomic, retain) NSMutableArray * yesterdayCheckins;
@property (nonatomic, retain) NSMutableArray * nonCityCheckins;

- (void)checkinResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (void) doInitialDisplay;
- (IBAction) addFriend;
- (IBAction) viewNextWelcomeImage;
- (IBAction) viewPreviousWelcomeImage;
- (IBAction) displayOlderCheckins;
- (void) setupSplashAnimation;
- (void) instaCheckin:(NSNotification *)inNotification;
- (void) setUserIconViewCustom:(FSUser*)user;
- (IBAction) displayTwitterXAuthLogin;
//- (void) showSplash;

@end

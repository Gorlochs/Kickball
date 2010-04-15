//
//  TwTabController.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/21/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TwTabController.h"
// Controllers

#import "TwitEditorController.h"
#import "HomeViewController.h"
#import "SelectImageSource.h"
#import "SettingsController.h"
#import "LocationManager.h"
#import "RepliesListController.h"
#import "DirectMessagesController.h"
#import "NavigationRotateController.h"
#import "TweetQueueController.h"
#import "AboutController.h"
#import "LoginController.h"
#import "FollowersController.h"
#import "MyTweetViewController.h"
#import "SearchController.h"
#import "MoreController.h"

@implementation TwTabController

- (UIViewController *)createViewController: (Class)class nibName: (NSString*)nibName tabIconName: (NSString *)iconName tabTitle: (NSString *)tabTitle
{
    UIViewController *theController = nil;
    
    if (nibName)
        theController = [[[class alloc] initWithNibName:nibName bundle: nil] autorelease];
    else
        theController = [[[class alloc] init] autorelease];
    
    theController.tabBarItem.image = [UIImage imageNamed:iconName];
    theController.title = NSLocalizedString(tabTitle, @"");
    
    return theController;
}

- (void)initializeTabItemControllers 
{
    UIViewController *theController = nil;
    NSMutableArray *controllers = [[[NSMutableArray alloc] initWithCapacity:4] autorelease];
    
    theController = [self createViewController:[HomeViewController class] 
                                       nibName:nil 
                                   tabIconName:@"home.tif" 
                                      tabTitle:@"Home"];
    [controllers addObject:theController];
    
	theController = [self createViewController:[RepliesListController class] 
                                       nibName:@"UserMessageList" 
                                   tabIconName:@"mentions.tif" 
                                      tabTitle:@"Replies"];
    [controllers addObject:theController];
    
	theController = [self createViewController:[DirectMessagesController class] 
                                       nibName:@"UserMessageList" 
                                   tabIconName:@"messages.tif" 
                                      tabTitle:@"Messages"];
    [controllers addObject:theController];
    
	theController = [self createViewController:[TweetQueueController class] 
                                       nibName:@"TweetQueue" 
                                   tabIconName:@"unsent.tif" 
                                      tabTitle:[TweetQueueController queueTitle]];
    [controllers addObject:theController];

	theController = [self createViewController:[MoreController class] 
                                       nibName:nil 
                                   tabIconName:@"house.png" 
                                      tabTitle:@"More"];
    [controllers addObject:theController];
    
    [self setViewControllers:controllers];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    [self initializeTabItemControllers];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc 
{
    [super dealloc];
}

@end
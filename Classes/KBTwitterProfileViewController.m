//
//  KBTwitterProfileViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBTwitterProfileViewController.h"


@implementation KBTwitterProfileViewController

@synthesize screenname;

- (void)viewDidLoad {
    screenNameLabel.text = @"";
    fullName.text = @"";
    location.text = @"";
    numberOfFriends.text = @"";
    numberOfFollowers.text = @"";
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRetrieved:) name:kTwitterUserInfoRetrievedNotificationKey object:nil];
    [self startProgressBar:@"Retrieving user information..."];
    [twitterEngine getUserInformationFor:screenname];
}

- (void) userRetrieved:(NSNotification*)inNotification {
    NSDictionary *userDictionary = [[inNotification userInfo] objectForKey:@"userInfo"];
    NSLog(@"user: %@", userDictionary);
    screenNameLabel.text = [userDictionary objectForKey:@"screen_name"];
    fullName.text = [userDictionary objectForKey:@"name"];
    location.text = [userDictionary objectForKey:@"location"];
    numberOfFriends.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"friends_count"] intValue]];
    numberOfFollowers.text = [NSString stringWithFormat:@"%d", [[userDictionary objectForKey:@"followers_count"] intValue]];
    
    description = [[IFTweetLabel alloc] initWithFrame:CGRectMake(12, 170, 300, 60)];
    description.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    description.font = [UIFont fontWithName:@"Georgia" size:12.0];
    description.backgroundColor = [UIColor clearColor];
    description.linksEnabled = YES;
    description.numberOfLines = 0;
    //tweetText.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    //tweetText.shadowOffset = CGSizeMake(1.0, 1.0);
    [self.view addSubview:description];
    description.text = [userDictionary objectForKey:@"description"];
    
    CGSize maximumLabelSize = CGSizeMake(300,60);
    CGSize expectedLabelSize = [description.text sizeWithFont:description.font 
                                               constrainedToSize:maximumLabelSize 
                                                   lineBreakMode:UILineBreakModeTailTruncation]; 
    
    //adjust the label the the new height.
    CGRect newFrame = description.frame;
    newFrame.size.height = expectedLabelSize.height;
    description.frame = newFrame;
    
    [self stopProgressBar];
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
    [super dealloc];
}


@end

//
//  AccountOptionsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/26/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFacebookViewController.h"
#import "XAuthTwitterEngineDelegate.h"
#import "KBTwitterManagerDelegate.h"
#import "OAToken.h"

#define kOAuthConsumerKey		@"qyx7QFTRxkJ0BbYN6ZKqbg"		// Replace these with your consumer key 
#define	kOAuthConsumerSecret	@"5Naqknb57AxYWVdonjl0H9Iod7Kq76MWcvnYqAEpo"		// and consumer secret from http://twitter.com/oauth_clients/details/<your app id>
#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"

@class XAuthTwitterEngine;

@interface AccountOptionsViewController : AbstractFacebookViewController <UITextFieldDelegate, XAuthTwitterEngineDelegate, KBTwitterManagerDelegate> {
    IBOutlet UITableViewCell *foursquareCell;
    IBOutlet UITableViewCell *twitterCell;
    IBOutlet UITableViewCell *facebookCell;
	IBOutlet UITableViewCell *uberCell;
    IBOutlet UIImageView *whyThisImage;
    
    IBOutlet UITextField *foursquareUsername;
    IBOutlet UITextField *foursquarePassword;
    IBOutlet UITextField *twitterUsername;
    IBOutlet UITextField *twitterPassword;
    
    IBOutlet UISwitch *kickballAccountLinkingSwitch;
    IBOutlet UISwitch *twitterGeotaggingSwitch;
    IBOutlet UISwitch *postPhotosToFacebookSwitch;
    
    IBOutlet UIButton *whatIsThisButton;
    BOOL isWhatsThisDisplayed;
    
    CGFloat animatedDistance;
	UIButton *fbButton;
	
	IBOutlet UIButton *vote1Butt;
	IBOutlet UIButton *vote2Butt;
	IBOutlet UIButton *vote3Butt;
	IBOutlet UIButton *vote4Butt;
	IBOutlet UIButton *x4SQ;
	IBOutlet UIButton *xTW;
	IBOutlet UIButton *xFB;

}

- (IBAction) xAuthAccessTokenRequestButtonTouchUpInside;
- (IBAction) authenticateFoursquare;
- (IBAction) linkKickballAccount;
- (IBAction) enableTwitterGeotagging;
- (IBAction) postPhotosToFacebook;
- (IBAction) displayWhatsThis;
- (IBAction) nextOptionView;

- (IBAction) doVote1;
- (IBAction) doVote2;
- (IBAction) doVote3;
- (IBAction) doVote4;

@end

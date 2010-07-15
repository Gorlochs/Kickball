//
//  KBWebViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"

@interface KBWebViewController : KBBaseViewController <UIWebViewDelegate>{
    UIWebView *theWebView;
    NSString *urlString;
	NSString *twitterUrlString;
  //stay key-value coding-compliant when going from twitter -> webpage:
    IBOutlet UIButton *homeButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *mentionsButton;    
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *directMessageButton;
    IBOutlet UIButton *backButton;	
	IBOutlet UIButton *forwardButton;
}


@property (nonatomic, retain) IBOutlet UIWebView *theWebView;

- (IBAction) forward;
- (IBAction) back;
- (IBAction) dismissView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrlString:(NSString*)url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTwitterUrlString:(NSString*)url;

@end

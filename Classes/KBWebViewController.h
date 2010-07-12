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
    UIWebView *webView;
    NSString *urlString;
	NSString *twitterUrlString;
  //stay key-value coding-compliant when going from twitter -> webpage:
    IBOutlet UIButton *homeButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *mentionsButton;    
    IBOutlet UIButton *timelineButton;
    IBOutlet UIButton *directMessageButton;
    IBOutlet UIButton *backButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction) dismissView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrlString:(NSString*)url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTwitterUrlString:(NSString*)url;

@end

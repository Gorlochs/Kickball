//
//  ForgotPasswordWebViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"

@interface KBWebViewController : KBBaseViewController {
    UIWebView *webView;
    NSString *urlString;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *urlString;

- (IBAction) dismissView;

@end

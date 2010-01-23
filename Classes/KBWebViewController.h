//
//  ForgotPasswordWebViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/18/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBWebViewController : UIViewController {
    UIWebView *webView;
    NSString *urlString;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *urlString;

- (IBAction) dismiss;

@end

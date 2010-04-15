// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "XAuthTwitterEngine.h"
#import "TwActivityIndicator.h"

extern const NSString *kNewAccountLoginDataKey;
extern const NSString *kOldAccountLoginDataKey;
extern const NSString *LoginControllerAccountDidChange;

@class UserAccount;

@interface LoginController : UIViewController <UITextFieldDelegate, SA_OAuthTwitterControllerDelegate>
{
@private
//	IBOutlet UIButton *oAuthOKButton;
	
//    IBOutlet id cancelButton;
//    IBOutlet id loginButton;
//    IBOutlet id loginField;
//    IBOutlet id passwordField;
//	IBOutlet id rememberSwitch;
//	IBOutlet id iconView;
//    IBOutlet id authTypeSegment;
//    IBOutlet UIView *accountView;
//    IBOutlet UIView *oAuthView;    
    UserAccount *_currentAccount;
    BOOL oAuthAuthorization;
    MGTwitterEngine *twitter;
    NSString *twitterUserCredentialID;
//    TwActivityIndicator *progress;
    
    IBOutlet UITextField *usernameTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UIButton *sendTweetButton;
	XAuthTwitterEngine *twitterEngine;
}

@property (nonatomic, retain) UITextField *usernameTextField, *passwordTextField;
@property (nonatomic, retain) UIButton *sendTweetButton;
@property (nonatomic, retain) XAuthTwitterEngine *twitterEngine;

- (IBAction)xAuthAccessTokenRequestButtonTouchUpInside;
- (IBAction)sendTestTweetButtonTouchUpInside;

- (id)initWithUserAccount:(UserAccount*)account;

- (IBAction)cancel:(id)sender;

- (IBAction)login:(id)sender;

- (void)showOAuthViewInController:(UINavigationController *)aNavigationController;

//- (IBAction)changeAuthTypeClick:(id)sender;

//- (IBAction)oAuthOKClick;

@end

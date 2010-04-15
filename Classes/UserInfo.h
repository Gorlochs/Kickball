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
#import "UserInfoView.h"

@class MGTwitterEngine;
@class CustomImageView;

enum {
    USDescription,
    USDevice,
    USAction
};

enum {
    UActionDirectMessageIndex,
    UActionReplyIndex,
    UActionRecentIndex,
    UActionFollowersIndex
};

@interface UserInfo : UIViewController <UITableViewDelegate, UITableViewDataSource, UserInfoViewDelegate>
{
    UIWebView *infoView;
	UISwitch *notifySwitch;
    
    UISegmentedControl *followButton;
    UIButton *followBtn;
	UITableView *tableView;
    
	BOOL _gotInfo;
	BOOL _shouldUpdateUserInfo;
	MGTwitterEngine *_twitter;
	NSString *_username;
    BOOL _following;
	NSString *isUserReceivingUpdatesForConnectionID;
    NSString *userInfoConnectionID;
	NSString *followersCount;
    BOOL _isDirectMessage;
    UserInfoView *_userInfoView;
    NSMutableArray *_userTableSection;
    NSMutableDictionary *_userTableImages;
}
- (id)initWithUserName:(NSString*)uname;
- (IBAction)follow;
- (IBAction)followers;
- (IBAction)sendMessage;
- (IBAction)sendReply;
- (IBAction)showTwitts;
- (IBAction)notifySwitchChanged;

@property (nonatomic, copy) NSString *isUserReceivingUpdatesForConnectionID;
@property (nonatomic, copy) NSString *userInfoConnectionID;

@property (nonatomic, retain) IBOutlet UIWebView *infoView;
@property (nonatomic, retain) IBOutlet UISwitch *notifySwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *followButton;
@property (nonatomic, retain) IBOutlet UIButton *followBtn;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end

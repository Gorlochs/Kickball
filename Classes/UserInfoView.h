//
//  UserInfoView.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/24/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UserInfoButtonDetail = 1,
    UserInfoButtonFollow = 2
} UserInfoButtonType;

@protocol UserInfoViewDelegate
@optional

- (void)userDetailPressed;
- (void)userFollowPressed;

@end

@interface UserInfoView : UIView 
{
    NSString                    *username;
    NSString                    *screenname;
    NSString                    *location;
    UIImage                     *avatar;
    BOOL                         follow;
    int                          buttons;
    id <UserInfoViewDelegate>    delegate;
    UIButton                    *detailButton;
    UIButton                    *followButton;
}

@property (nonatomic, copy)     NSString                    *username;
@property (nonatomic, copy)     NSString                    *screenname;
@property (nonatomic, copy)     NSString                    *location;
@property (nonatomic, retain)   UIImage                     *avatar;
@property (nonatomic)           BOOL                         follow;
@property (nonatomic)           int                          buttons;
@property (nonatomic, assign)   id <UserInfoViewDelegate>    delegate;

- (void)disableFollowingButton:(BOOL)disabled;
- (void)hideFollowingButton:(BOOL)hide;

@end


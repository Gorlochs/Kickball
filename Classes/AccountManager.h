//
//  AccountManager.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/15/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kInvalidUserIndex   -1
/*
@interface AccountManager : NSObject 
{
    NSMutableArray *_users;
    int _currentUserIndex;
}

+ (AccountManager *)manager;
+ (NSString *)loggedUserName;
+ (NSString *)loggedUserPassword;

- (NSUInteger)accountCount;
- (NSString *)userName:(NSUInteger)index;
- (NSString *)userPassword:(NSString *)userName;

// User data managament
- (void)addUser:(NSString *)userName password:(NSString *)password;
- (void)updateUser:(NSString *)userName newUserName:(NSString *)newUserName newPassword:(NSString *)password;
- (void)removeUser:(NSString *)userName;

// Login methods
- (void)login:(NSString *)userName;

@end
*/

@class UserAccount;

@interface AccountManager : NSObject
{
@private
    NSMutableDictionary     *_accounts;
    UserAccount             *_loggedUserAccount;
}

@property (nonatomic, readonly) UserAccount *loggedUserAccount;

+ (AccountManager*)manager;

- (void)saveAccount:(UserAccount*)account;

- (void)replaceAccount:(UserAccount*)oldAccount with:(UserAccount*)newAccount;

- (void)removeAccount:(UserAccount*)account;

- (UserAccount*)accountByUsername:(NSString*)username;

- (NSArray*)allAccountUsername;

- (BOOL)hasAccountWithUsername:(NSString*)username;

- (void)login:(UserAccount*)account;

- (void)clearLoggedObject;

- (BOOL)isValidLoggedUser;

@end

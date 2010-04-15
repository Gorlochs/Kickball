//
//  AccountManager.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/15/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "AccountManager.h"
#import "MGTwitterEngine.h"
#import "UserAccount.h"

#define ACCOUNT_MANAGER_KEY             @"Accounts"
#define ACCOUNT_MANAGER_LAST_USER_KEY   @"AccountLastUser"
#define SEC_ATTR_SERVER                 @"twitter.com"

@interface AccountManager(Private)
- (NSMutableDictionary *)prepareSecItemEntry:(NSString *)server user:(NSString *)userName;
- (void)updateStandadUserDefaults;
- (void)updateLoggedUserAccount:(UserAccount*)account;
- (void)loadSavedAccounts;
- (BOOL)validateAccount:(UserAccount*)account;
@end

@implementation AccountManager

@synthesize loggedUserAccount = _loggedUserAccount;

+ (AccountManager*)manager
{
    static AccountManager *manager = nil;
    
    if (manager == nil)
        manager = [[AccountManager alloc] init];
    return manager;
}

- (id)init
{
    if (self = [super init])
    {
        _accounts = [[NSMutableDictionary alloc] init];
        _loggedUserAccount = nil;
        [self loadSavedAccounts];
    }
    return self;
}

- (void)dealloc
{
    [self clearLoggedObject];
    [_accounts release];
    [super dealloc];
}

- (void)saveAccount:(UserAccount*)account
{
    YFLog(@"Save account method");
    if (account == nil)
        return;
    
    BOOL isNewAccount = ![self hasAccountWithUsername:account.username];
    BOOL isValid = [self validateAccount:account];
    
    YFLog(@"Account present = %i", isNewAccount);
    if (isNewAccount && isValid)
    {
        // Add and save new account
        NSString *securityString = [account secretData];
        NSData *secData = [securityString dataUsingEncoding:NSUTF8StringEncoding];

        // Prepate SecItemEnty
        NSMutableDictionary *secItemEntry = [self prepareSecItemEntry:SEC_ATTR_SERVER user:account.username];
        [secItemEntry setObject:secData forKey:(id)kSecValueData];
        
        OSStatus err = SecItemAdd((CFDictionaryRef)secItemEntry, NULL);
        if (err == errSecDuplicateItem)
        {
            [secItemEntry removeObjectForKey:(id)kSecValueData];
            NSMutableDictionary *attrToUpdate = [[NSMutableDictionary alloc] init];
            
            [attrToUpdate setObject:secData forKey:(id)kSecValueData];
            err = SecItemUpdate((CFDictionaryRef)secItemEntry, (CFDictionaryRef)attrToUpdate);
            [attrToUpdate release];
        }
        
        YFLog(@"SecItemAdd result = %i (noErr = %i)", err, noErr);
        if (err == noErr || err == errSecDuplicateItem)
        {
            // Add account to dictionary
            [_accounts setObject:account forKey:account.username];
            
            // Update user defaults
            [self updateStandadUserDefaults];
        }
    }
}

- (void)replaceAccount:(UserAccount*)oldAccount with:(UserAccount*)newAccount
{
    YFLog(@"Replace account method");
    if (oldAccount == nil || newAccount == nil)
        return;
    
    BOOL hasOldAccount = [self hasAccountWithUsername:oldAccount.username];
    BOOL hasNewAccount = [self hasAccountWithUsername:newAccount.username];
    
    YFLog(@"Has oldAccount = %i, has newAccount = %i", hasOldAccount, hasNewAccount);
    if (hasOldAccount)
    {
        BOOL isValid = [self validateAccount:newAccount];
        if (!isValid)
            return;
        
        // Replace user data
        if ([oldAccount.username compare:newAccount.username] == NSOrderedSame)
        {
            YFLog(@"Replace security data");
            
            NSString *secString = [newAccount secretData];
            
            NSMutableDictionary *secItemEntry = [self prepareSecItemEntry:SEC_ATTR_SERVER user:oldAccount.username];
            
            NSData *secData = [secString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *attrToUpdate = [[NSMutableDictionary alloc] init];
            
            [attrToUpdate setObject:secData forKey:(id)kSecValueData];
            
            OSStatus err = SecItemUpdate((CFDictionaryRef)secItemEntry, (CFDictionaryRef)attrToUpdate);
            
            YFLog(@"SecItemAdd result = %i (noErr = %i)", err, noErr);
            if (err == noErr)
            {
                // Update accounts dictionary
                [_accounts removeObjectForKey:oldAccount.username];
                [_accounts setObject:newAccount forKey:newAccount.username];
                
                // Update app defauls
                [self updateStandadUserDefaults];
            }
            
            [attrToUpdate release];            
        }
        else if (!hasNewAccount)
        {
            YFLog(@"Remove old and add new accounts");
            // Delete old account
            [self removeAccount:oldAccount];
            // Add new account
            [self saveAccount:newAccount];
        }
    }
}

- (void)removeAccount:(UserAccount*)account
{
    YFLog(@"Reemove account method");
    BOOL hasAccount = [self hasAccountWithUsername:account.username];
    
    YFLog(@"Account present = %i", hasAccount);
    if (hasAccount)
    {
        NSMutableDictionary *secItemEntry = [self prepareSecItemEntry:SEC_ATTR_SERVER user:account.username];
        
        // Remove data from KeyChain
        OSStatus err = SecItemDelete((CFDictionaryRef)secItemEntry);
        
        YFLog(@"SecItemAdd result = %i (noErr = %i)", err, noErr);
        if (err == noErr)
        {
            // Remove account from dictionary
            [_accounts removeObjectForKey:account.username];
            
            // Update app defaults
            [self updateStandadUserDefaults];
        }
    }
}

- (UserAccount*)accountByUsername:(NSString*)username
{
    if (_accounts == nil)
        return nil;
    
    UserAccount *account = [_accounts objectForKey:username];
    if (account == nil)
        return nil;
    
    return account;
    //return [[account retain] autorelease];
}

- (NSArray*)allAccountUsername
{
    return [NSArray arrayWithArray:[_accounts allKeys]];
}

- (BOOL)hasAccountWithUsername:(NSString*)username
{
    return !([self accountByUsername:username] == nil);
}

- (void)login:(UserAccount*)account
{
    if (account)
    {
        if (account.authType == TwitterAuthCommon)
        {
            [MGTwitterEngine setUsername:account.username password:account.secretData remember:NO];
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:account.username, @"login", account.secretData, @"password", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"AccountChanged" 
                                                                object: nil
                                                              userInfo: userInfo];
        }
        [self updateLoggedUserAccount:account];
    }
}

- (void)clearLoggedObject
{
    if (_loggedUserAccount)
        [_loggedUserAccount release];
}

- (BOOL)isValidLoggedUser
{
    return !(self.loggedUserAccount == nil);
}

@end

@implementation AccountManager(Private)

- (NSMutableDictionary *)prepareSecItemEntry:(NSString *)server user:(NSString *)userName
{
    NSMutableDictionary *secItemEntry = [[NSMutableDictionary alloc] init];
    
    [secItemEntry setObject:(id)kSecClassInternetPassword forKey:(id)kSecClass];
    [secItemEntry setObject:server forKey:(id)kSecAttrServer];
    [secItemEntry setObject:userName forKey:(id)kSecAttrAccount];
    return [secItemEntry autorelease];
}

- (void)updateStandadUserDefaults
{
    //NSArray *usernames = [self allAccountUsername];
    
    NSMutableArray *accData = [NSMutableArray array];
    
    for (NSString *key in _accounts)
    {
        UserAccount *acc = [_accounts objectForKey:key];
        
        NSNumber *type = [NSNumber numberWithInt:acc.authType];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:acc.username forKey:@"username"];
        [dict setObject:type forKey:@"authtype"];
        
        [accData addObject:dict];
    }
    
    //[[NSUserDefaults standardUserDefaults] setObject:usernames forKey:ACCOUNT_MANAGER_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:accData forKey:ACCOUNT_MANAGER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateLoggedUserAccount:(UserAccount*)account
{
    [self clearLoggedObject];
    
    _loggedUserAccount = [account retain];
	[_loggedUserAccount updateUserInfo];
    
    [[NSUserDefaults standardUserDefaults] setObject:account.username forKey:ACCOUNT_MANAGER_LAST_USER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadSavedAccounts
{
    NSArray *accounts = [[NSUserDefaults standardUserDefaults] arrayForKey:ACCOUNT_MANAGER_KEY];
    
    // Load all account data
    //for (NSString *username in accounts)
    for (NSDictionary *dict in accounts)
    {
        if (!dict)
            continue;
        
        NSString *username = [dict objectForKey:@"username"];
        NSNumber *type = [dict objectForKey:@"authtype"];
        
        NSMutableDictionary *secItemEntry = [self prepareSecItemEntry:SEC_ATTR_SERVER user:username];
        
        [secItemEntry setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        [secItemEntry setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        
        CFTypeRef result = NULL;
        OSStatus err = SecItemCopyMatching((CFDictionaryRef)secItemEntry, &result);
        
        NSString *secData = nil;
        if (err == noErr && result)
        {
			NSData *theData = (NSData *)result;
            secData = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
            
            UserAccount *account = [[UserAccount alloc] init];
            account.username = username;
            account.secretData = secData;
            if (type)
                account.authType = [type intValue];
            
            [_accounts setObject:account forKey:account.username];
            
            [account release];
            [secData release];
        }
		
		if (NULL != result)
		{
			CFRelease(result);
		}
    }
    
    NSString *lastAccountUsername = [[NSUserDefaults standardUserDefaults] stringForKey:ACCOUNT_MANAGER_LAST_USER_KEY];
    
    UserAccount *lastAccount = [self accountByUsername:lastAccountUsername];
    [self login:lastAccount];
}

- (BOOL)validateAccount:(UserAccount*)account
{
    if (!account)
        return NO;
    
    BOOL valid = NO;
    
    
    valid = ([account.username length] > 0);
    
    return valid;
}

@end
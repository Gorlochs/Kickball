//
//  UserAccount.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 10/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "UserAccount.h"
#import "MGTwitterEngineFactory.h"

@implementation UserAccount

@synthesize username = _username;
@synthesize secretData = _secretData;
@synthesize authType = _authType;

- (id)init
{
    //NSAssert(NO, @"Object could not created");
    if (self = [super init])
    {
        self.authType = TwitterAuthCommon;		
    }
    return self;
}

- (void)dealloc
{
    self.username = nil;
    self.secretData = nil;
	[_twitter release];
	[_userInfoConnectionID release];
	[_userData release];
    [super dealloc];
}

- (void)updateUserInfo
{
	if (nil == _twitter)
	{
		MGTwitterEngineFactory *factory = [[MGTwitterEngineFactory alloc] init];
		_twitter = [[factory createTwitterEngineForUserAccount:self delegate:self] retain];
		[factory release];
	}
	
	[_userInfoConnectionID release];
	_userInfoConnectionID = [[_twitter getUserInformationFor:_username] retain];
}

- (id)valueForUndefinedKey:(NSString *)key
{
	return [_userData valueForKey:key];
}

#pragma mark MGTwitterEngine Delegate
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{	
    YFLog(@"NETWORK_FAILED: %@", connectionIdentifier);
    YFLog(@"%@", error);    
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
{
    YFLog(@"USER INFO RECEIVE");
	
    if (![_userInfoConnectionID isEqualToString:connectionIdentifier])
	{
		return;
	}
    
	[_userData release];
	_userData = [[userInfo objectAtIndex:0] retain];
	
	[_userInfoConnectionID release];
	_userInfoConnectionID = nil;
}

@end

// TwitterCommonUserAccount
/*
@implementation TwitterCommonUserAccount

@synthesize password = _password;

- (id)init
{
    return self;
}

- (void)dealloc
{
    self.password = nil;
    [super dealloc];
}

- (NSString*)secretData
{
    return self.password;
}

- (TwitterAuthType)authType
{
    return TwitterCommon;
}
@end

// TwitterOAuthUserAccount
@implementation TwitterOAuthUserAccount

@synthesize accessToken = _accessToken;

- (id)init
{
    return self;
}

- (void)dealloc
{
    self.accessToken = nil;
    [super dealloc];
}

- (TwitterAuthType)authType
{
    return TwitterOAuth;
}

@end
*/
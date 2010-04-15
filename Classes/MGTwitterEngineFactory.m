//
//  MGTwitterEngineFactory.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/5/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "MGTwitterEngine.h"
#import "SA_OAuthTwitterEngine.h"
#import "UserAccount.h"
#import "AccountManager.h"
#import "MGTwitterEngineFactory.h"
#include "config.h"
#import "XAuthTwitterEngine.h"

@implementation MGTwitterEngineFactory

+ (MGTwitterEngineFactory*)factory
{
    return [[[MGTwitterEngineFactory alloc] init] autorelease];
}

+ (MGTwitterEngine*)createTwitterEngineForCurrentUser:(id)del
{
    MGTwitterEngineFactory *factory = [[[MGTwitterEngineFactory alloc] init] autorelease];
    
    UserAccount *account = [[AccountManager manager] loggedUserAccount];
    if (account)
    {
        return [factory createTwitterEngineForUserAccount:account delegate:del];
    }
    return nil;
}

- (MGTwitterEngine*)createTwitterEngineForUserAccount:(UserAccount*)account delegate:(id)del
{
    MGTwitterEngine *engine = nil;
    
    int authType = [account authType];
    if (authType == TwitterAuthCommon)
    {
        engine = [[MGTwitterEngine alloc] initWithDelegate:del];
        if (engine)
            [MGTwitterEngine setUsername:account.username password:account.secretData];
    }
    else if (authType == TwitterAuthOAuth)
    {
        XAuthTwitterEngine *oaEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
        //SA_OAuthTwitterEngine *oaEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:del];
        
        [oaEngine setConsumerKey:kTweeteroConsumerKey];
        [oaEngine setConsumerSecret:kTweeteroConsumerSecret];
        //[oaEngine authorizeWithAccessTokenString:account.secretData];
        
        engine = oaEngine;
    }
    
    return [engine autorelease];
}

- (NSDictionary*)createTwitterAuthorizationFields:(UserAccount*)account
{
    if (account == nil)
        return nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (account.authType == TwitterAuthCommon)
    {
        [params setObject:[account username] forKey:@"a_username"];
        [params setObject:[account secretData] forKey:@"a_password"];
    }
    else if (account.authType == TwitterAuthOAuth)
    {
        XAuthTwitterEngine *oaEngine = [[XAuthTwitterEngine alloc] initXAuthWithDelegate:self];
        //SA_OAuthTwitterEngine *oaEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        
        [oaEngine setConsumerKey:kTweeteroConsumerKey];
        [oaEngine setConsumerSecret:kTweeteroConsumerSecret];
        //[oaEngine authorizeWithAccessTokenString:account.secretData];
        
        [params setObject:@"oauth" forKey:@"auth"];
        [params setObject:[account username] forKey:@"a_username"];
        
        if ([oaEngine isAuthorized])
        {
            UIAlertViewQuick(@"Cached xAuth token found!", @"This app was previously authorized for a Twitter account so you can press the second button to send a tweet now.", @"OK");
            //self.sendTweetButton.enabled = YES;
        }
        
//        NSDictionary *oauthFields = [oaEngine authRequestFields];
//        NSMutableString *credential = [NSMutableString stringWithString:@"https://twitter.com/account/verify_credentials.xml?"];
//        for (NSString *param_name in [oauthFields allKeys]) {
//            NSString *param_val = [oauthFields objectForKey:param_name];
//            if ((param_name && [param_name length] > 0) && (param_val && [param_val length] > 0)) {
//                [credential appendFormat:@"%@=%@&", param_name, param_val];
//            }
//        }
//        NSString *verify_url_value = [credential substringToIndex:[credential length] - 1];
//        
//        [params setObject:verify_url_value forKey:@"a_verify_url"];
        [oaEngine release];
    }
    
    return params;
}

@end

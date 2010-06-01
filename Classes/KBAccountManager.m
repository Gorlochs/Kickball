//
//  KBAccountManager.m
//  Kickball
//
//  Created by Shawn Bernard on 5/21/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBAccountManager.h"

#define USES_TWITTER_KEY @"usesTwitter"
#define USES_FACEBOOK_KEY @"usesFacebook"
#define FACEBOOK_NOTHANKS_CLICKED @"facebookNoThanksClicked"
#define TWITTER_NOTHANKS_CLICKED @"twitterNoThanksClicked"

static KBAccountManager *accountManager = nil;

@implementation KBAccountManager

@synthesize usesTwitter;
@synthesize usesFacebook;

#pragma mark -
#pragma mark custom getters and setters

- (void) setUsesTwitter:(BOOL)b {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:b forKey:USES_TWITTER_KEY];
	[userDefaults setBool:YES forKey:TWITTER_NOTHANKS_CLICKED]; // before the user says 'no thanks', we need to show the tab
    if (!b) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAppropriateTabs" object:nil userInfo:nil];
    }
}

- (BOOL) usesTwitterOrHasNotDecided {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // if the value doesn't exist, that means a user hasn't chosen yet, so display the tab
    return [userDefaults boolForKey:USES_TWITTER_KEY] || (![userDefaults boolForKey:USES_TWITTER_KEY] && ![userDefaults boolForKey:TWITTER_NOTHANKS_CLICKED]);
}

- (BOOL) usesTwitter {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:USES_TWITTER_KEY];
}

- (void) setUsesFacebook:(BOOL)b {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:b forKey:USES_FACEBOOK_KEY];
	[userDefaults setBool:YES forKey:FACEBOOK_NOTHANKS_CLICKED]; // before the user says 'no thanks', we need to show the tab
    if (!b) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAppropriateTabs" object:nil userInfo:nil];
    }
}

- (BOOL) usesFacebookOrHasNotDecided {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // if the value doesn't exist, that means a user hasn't chosen yet, so display the tab
    return [userDefaults boolForKey:USES_FACEBOOK_KEY] || (![userDefaults boolForKey:USES_FACEBOOK_KEY] && ![userDefaults boolForKey:FACEBOOK_NOTHANKS_CLICKED]);
}

- (BOOL) usesFacebook {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSLog(@"![userDefaults boolForKey:USES_FACEBOOK_KEY]: %d", ![userDefaults boolForKey:USES_FACEBOOK_KEY]);
	NSLog(@"![userDefaults boolForKey:FACEBOOK_NOTHANKS_CLICKED]: %d", ![userDefaults boolForKey:FACEBOOK_NOTHANKS_CLICKED]);
	NSLog(@"[userDefaults boolForKey:USES_FACEBOOK_KEY]: %d", [userDefaults boolForKey:USES_FACEBOOK_KEY]);
    return [userDefaults boolForKey:USES_FACEBOOK_KEY];
}

#pragma mark -
#pragma mark singleton stuff

+ (KBAccountManager*) sharedInstance {
	if(!accountManager)  {
        accountManager = [[KBAccountManager allocWithZone:nil] init];
    }
    
	return accountManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
		if (accountManager == nil) 
			accountManager = [super allocWithZone:zone];
    }
	
    return accountManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end

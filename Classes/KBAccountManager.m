//
//  KBAccountManager.m
//  Kickball
//
//  Created by Shawn Bernard on 5/21/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBAccountManager.h"
#import "FacebookProxy.h"
#import "KBTwitterManager.h"
#import "FoursquareAPI.h"

#define USES_TWITTER_KEY @"usesTwitter"
#define USES_FACEBOOK_KEY @"usesFacebook"
#define FACEBOOK_NOTHANKS_CLICKED @"facebookNoThanksClicked"
#define TWITTER_NOTHANKS_CLICKED @"twitterNoThanksClicked"
#define SHOULD_POST_PHOTOS_TO_FACEBOOK_KEY @"shouldPostPhotosToFacebook"
#define DEFAULT_POST_TO_TWITTER @"defaultTwitter"
#define DEFAULT_POST_TO_FACEBOOK @"defaultFacebook"
#define DEFAULT_POST_TO_FOURSQUARE @"defaultFoursquare"
#define FIRST_RUN_COMPLETED @"firstRunCompleted"
#define TW_POLLINATES_4SQ @"twitterPollinatesFoursquare"
#define TW_POLLINATES_FB @"twitterPollinatesFacebook"
#define FB_POLLINATES_4SQ @"facebookPollinatesFoursquare"
#define FB_POLLINATES_TW @"facebookPollinatesTwitter"
#define FOURSQ_POLLINATES_TW @"foursquarePollinatesTwitter"
#define FOURSQ_POLLINATES_FB @"foursquarePollinatesFacebook"

static KBAccountManager *accountManager = nil;
static BOOL initialized = NO;

@implementation KBAccountManager

@synthesize usesTwitter;
@synthesize usesFacebook;
@synthesize shouldPostPhotosToFacebook;
@synthesize usesFoursquare;

#pragma mark -
#pragma mark custom getters and setters

- (void) setUsesTwitter:(BOOL)b {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:b forKey:USES_TWITTER_KEY];
	[userDefaults setBool:YES forKey:TWITTER_NOTHANKS_CLICKED]; // before the user says 'no thanks', we need to show the tab
}

- (BOOL) usesTwitterOrHasNotDecided {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // if the value doesn't exist, that means a user hasn't chosen yet, so display the tab
    return [userDefaults boolForKey:USES_TWITTER_KEY] || (![userDefaults boolForKey:USES_TWITTER_KEY] && ![userDefaults boolForKey:TWITTER_NOTHANKS_CLICKED]);
}
-(BOOL) usesGeoTag{
	return YES;
}
-(void) setUsesGeoTag:(BOOL)b {
	usesGeoTag = b;
}

-(BOOL) usesFoursquare{
	return [[FoursquareAPI sharedInstance] isAuthenticated];
}

- (BOOL) usesTwitter {
	return [[[KBTwitterManager twitterManager] twitterEngine] isAuthorized];
	/*
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:USES_TWITTER_KEY];
	 */
}


- (void) setUsesFacebook:(BOOL)b {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:b forKey:USES_FACEBOOK_KEY];
	[userDefaults setBool:YES forKey:FACEBOOK_NOTHANKS_CLICKED]; // before the user says 'no thanks', we need to show the tab
}

- (BOOL) usesFacebookOrHasNotDecided {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // if the value doesn't exist, that means a user hasn't chosen yet, so display the tab
    return [userDefaults boolForKey:USES_FACEBOOK_KEY] || (![userDefaults boolForKey:USES_FACEBOOK_KEY] && ![userDefaults boolForKey:FACEBOOK_NOTHANKS_CLICKED]);
}

- (BOOL) usesFacebook {
	return [[FacebookProxy instance] isAuthorized];
	/*
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	DLog(@"![userDefaults boolForKey:USES_FACEBOOK_KEY]: %d", ![userDefaults boolForKey:USES_FACEBOOK_KEY]);
	DLog(@"![userDefaults boolForKey:FACEBOOK_NOTHANKS_CLICKED]: %d", ![userDefaults boolForKey:FACEBOOK_NOTHANKS_CLICKED]);
	DLog(@"[userDefaults boolForKey:USES_FACEBOOK_KEY]: %d", [userDefaults boolForKey:USES_FACEBOOK_KEY]);
    return [userDefaults boolForKey:USES_FACEBOOK_KEY];
	 */
}

- (void) setShouldPostPhotosToFacebook:(BOOL)shouldPostPhotos {
	[[NSUserDefaults standardUserDefaults] setBool:shouldPostPhotos forKey:SHOULD_POST_PHOTOS_TO_FACEBOOK_KEY];
}

- (BOOL) shouldPostPhotosToFacebook {
	return [[NSUserDefaults standardUserDefaults] boolForKey:SHOULD_POST_PHOTOS_TO_FACEBOOK_KEY];
}

-(void)setDefaultPostToTwitter:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:DEFAULT_POST_TO_TWITTER];
}

-(void)setDefaultPostToFacebook:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:DEFAULT_POST_TO_FACEBOOK];
}

-(void)setDefaultPostToFoursquare:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:DEFAULT_POST_TO_FOURSQUARE];
}

-(BOOL)defaultPostToTwitter{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:DEFAULT_POST_TO_TWITTER];
}

-(BOOL)defaultPostToFacebook{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:DEFAULT_POST_TO_FACEBOOK];
}
-(BOOL)defaultPostToFoursquare{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:DEFAULT_POST_TO_FOURSQUARE];
}
-(BOOL)twitterPollinatesFoursquare{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:TW_POLLINATES_4SQ];
}
-(BOOL)twitterPollinatesFacebook{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:TW_POLLINATES_FB];
}
-(BOOL)facebookPollinatesFoursquare{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:FB_POLLINATES_4SQ];
}
-(BOOL)facebookPollinatesTwitter{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:FB_POLLINATES_TW];
}
-(BOOL)foursquarePollinatesTwitter{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:FOURSQ_POLLINATES_TW];
}
-(BOOL)foursquarePollinatesFacebook{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults boolForKey:FOURSQ_POLLINATES_FB];
}
-(void)setTwitterPollinatesFoursquare:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:TW_POLLINATES_4SQ];
}
-(void)setTwitterPollinatesFacebook:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:TW_POLLINATES_FB];
}
-(void)setFacebookPollinatesFoursquare:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:FB_POLLINATES_4SQ];
}
-(void)setFacebookPollinatesTwitter:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:FB_POLLINATES_TW];
}
-(void)setFoursquarePollinatesTwitter:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:FOURSQ_POLLINATES_TW];
}
-(void)setFoursquarePollinatesFacebook:(BOOL)should{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:should forKey:FOURSQ_POLLINATES_FB];
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

- (id)init {
	if(initialized)
		return accountManager;
	
	self = [super init];
    if (!self)
	{
		if(accountManager)
			[accountManager release];
		return nil;
	}
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	firstRunCompleted =  [userDefaults boolForKey:FIRST_RUN_COMPLETED];
	if (!firstRunCompleted) {
		[userDefaults setBool:YES forKey:DEFAULT_POST_TO_TWITTER];
		[userDefaults setBool:YES forKey:DEFAULT_POST_TO_FACEBOOK];
		[userDefaults setBool:YES forKey:DEFAULT_POST_TO_FOURSQUARE];
		[userDefaults setBool:YES forKey:FIRST_RUN_COMPLETED];
	}
	initialized = YES;
	return self;
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

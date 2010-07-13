//
//  TweetPhoto.h
//  TPAPITest
//
//  Created by David J. Hinson on 1/15/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//
//	Objective-C Class interface for the TweetPhoto API, as specified here: http://groups.google.com/group/tweetphoto/web

#import <Foundation/Foundation.h>
#import "ElementParser.h"
#import "Element.h"
#import "Photos.h"
#import "Profiles.h"
#import "Settings.h"
#import "Comments.h"
#import "Favorites.h"
#import "TweetPhotoResponse.h"
#import "SocialFeed.h"
#import "SocialFeedEvent.h"
#import "VoteStatus.h"

typedef enum {
	TweetPhotoSocialReturnTypeJSON,
	TweetPhotoSocialReturnTypeXML,
} TweetPhotoSocialReturnTypes;

typedef enum {
	TweetPhotoFeedTypeATOM,
	TweetPhotoFeedTypeRSS,
} TweetPhotoFeedTypes;

typedef enum {
	TweetPhotoCommentsReturnTypeJSON,
	TweetPhotoCommentsReturnTypeXML,
} TweetPhotoCommentsReturnTypes;

typedef enum {
	TweetPhotoFriendsReturnTypeJSON,
	TweetPhotoFriendsReturnTypeXML,
} TweetPhotoFriendsReturnTypes;

typedef enum {
	TweetPhotoFavoritesReturnTypeJSON,
	TweetPhotoFavoritesReturnTypeXML,
} TweetPhotoFavoritesReturnTypes;

typedef enum {
	TweetPhotoLocationReturnTypeJSON,
	TweetPhotoLocationReturnTypeXML,
} TweetPhotoLocationReturnTypes;

typedef enum {
	TweetPhotoSettingsReturnTypeJSON,
	TweetPhotoSettingsReturnTypeXML,
} TweetPhotoSettingsReturnTypes;

typedef enum {
	TweetPhotoDeletePhotoReturnTypeJSON,
	TweetPhotoDeletePhotoReturnTypeXML,
} TweetPhotoDeletePhotoReturnTypes;

typedef enum {
	TweetPhotoPhotoReturnTypeJSON,
	TweetPhotoPhotoReturnTypeXML,
} TweetPhotoPhotoReturnTypes;

typedef enum {
	TweetPhotoVoteReturnTypeJSON,
	TweetPhotoVoteReturnTypeXML,
} TweetPhotoVoteReturnTypes;

typedef enum {
	TweetPhotoHasVotedReturnTypeJSON,
	TweetPhotoHasVotedReturnTypeXML,
} TweetPhotoHasVotedReturnTypes;

typedef enum {
	TweetPhotoVoteTypeThumbsUp,
	TweetPhotoVoteTypeThumbsDown,
} TweetPhotoVoteTypes;
	
typedef enum {
	TweetPhotoSignInReturnTypeJSON,
	TweetPhotoSignInReturnTypeXML,
} TweetPhotoSignInReturnTypes;

typedef enum {
	TweetPhotoUploadReturnTypeJSON,
	TweetPhotoUploadReturnTypeXML,
} TweetPhotoUploadReturnTypes;

typedef enum {
	TweetPhotoCommentReturnTypeJSON,
	TweetPhotoCommentReturnTypeXML,
} TweetPhotoCommentReturnTypes;

typedef enum {
	TweetPhotoLeaderboardTypeViewed,
	TweetPhotoLeaderboardTypeCommented,
	TweetPhotoLeaderboardTypeVoted,
} TweetPhotoLeaderboardTypes;

typedef enum {
	TweetPhotoLeaderboardReturnTypeJSON,
	TweetPhotoLeaderboardReturnTypeXML,
} TweetPhotoLeaderboardReturnTypes;

typedef enum {
	TweetPhotoReturnTypeJSON,
	TweetPhotoReturnTypeXML,
	TweetPhotoReturnTypeRSS,
	TweetPhotoReturnTypeATOM,
} TweetPhotoReturnTypes;

typedef enum {
	TweetPhotoSortFilterComments,
	TweetPhotoSortFilterDate,
	TweetPhotoSortFilterViews,
} TweetPhotoSortFilters;

typedef enum {
	TweetPhotoSortAsc,
	TweetPhotoSortDesc,
} TweetPhotoSorts;

typedef enum {
	TweetPhotoSizeAll,
	TweetPhotoSizeBig,
	TweetPhotoSizeMedium,
	TweetPhotoSizeThumbnail,
} TweetPhotoSizes;

@interface TweetPhoto : NSObject {
	NSString * _apiKey;
	NSString * _identityToken;
	NSString * _identitySecret;
	NSString * _serviceName;
	BOOL       _isoAuth;
	NSInteger  _statusCode;
	NSDictionary * _headerFields;
}

@property BOOL                              isoAuth;							// Does the authentication use oAuth / Basic
@property NSInteger                         statusCode;							// HTTP Status Code
@property (retain,nonatomic) NSString     * apiKey;								// API Key (Supplied by TweetPhoto)
@property (retain,nonatomic) NSString     * identityToken;						// Identity Token / User ID
@property (retain,nonatomic) NSString     * identitySecret;						// Identity Secret / Password
@property (retain,nonatomic) NSString     * serviceName;						// Service Name (Twitter, Foursquare, Facebook)
@property (retain,nonatomic) NSDictionary * headerFields;						// HTTP Response Headers

-(id)initWithSetup:(NSString*)identityToken identitySecret:(NSString*)identitySecret apiKey:(NSString*)apiKey serviceName:(NSString*)serviceName isoAuth:(BOOL)isoAuth;

-(NSDate*)dateFromISO8601:(NSString*)str;

// Add/Delete Comment
-(NSData*)comment:(long long)userId photoId:(long long)photoId comment:(NSString*)comment returnType:(TweetPhotoCommentReturnTypes)returnType;
-(NSInteger)commentDelete:(long long)userId photoId:(long long)photoId commentId:(long long)commentId;

// Delete Photo
-(NSData*)deletePhoto:(long long)photoId returnType:(TweetPhotoDeletePhotoReturnTypes)returnType;

// Add/Delete Favorite
-(NSInteger)favoriteAdd:(long long)userId photoId:(long long)photoId;
-(NSInteger)favoriteDelete:(long long)userId photoId:(long long)photoId;

// Get All Comments for a User
-(NSData*)getComments:(long long)userId returnType:(TweetPhotoCommentsReturnTypes)returnType;

// Get All Comments for a User
-(NSData*)getComments:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoCommentsReturnTypes)returnType;

// Get Photo Comments
-(NSData*)getPhotoComments:(long long)photoId returnType:(TweetPhotoCommentsReturnTypes)returnType;

// Get Photo Comments
-(NSData*)getPhotoComments:(long long)photoId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoCommentsReturnTypes)returnType;

// Get User Comments
-(NSData*)getUserComments:(long long)userId returnType:(TweetPhotoCommentsReturnTypes)returnType;

// Get User Comments
-(NSData*)getUserComments:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoCommentsReturnTypes)returnType;

// Get Favorites
-(NSData*)getFavorites:(long long)userId returnType:(TweetPhotoFavoritesReturnTypes)returnType;

// Get Favorites
-(NSData*)getFavorites:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoFavoritesReturnTypes)returnType;

// Get Feed
-(NSData*)getFeed:(NSString*)userName feedType:(TweetPhotoFeedTypes)feedType;

// Get Favorites
-(NSData*)getFriends:(long long)userId returnType:(TweetPhotoFriendsReturnTypes)returnType;

// Get Friends
-(NSData*)getFriends:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoFriendsReturnTypes)returnType;

// Get Leaderboard
-(NSData*)getLeaderboard:(TweetPhotoLeaderboardTypes)leaderboardType returnType:(TweetPhotoLeaderboardReturnTypes)returnType;

// Linked Services
-(NSData*)getLinkedServices;
-(Profiles*)linkedServices;
-(NSData*)linkService:(NSString*)apiKey serviceName:(NSString*)serviceName identityToken:(NSString*)identityToken identitySecret:(NSString*)identitySecret;
-(NSData*)unlinkService:(NSString*)serviceName;

// Get Photos
-(NSData*)getPhotos:(TweetPhotoReturnTypes)returnType;
-(NSData*)getPhotos:(long long)userId returnType:(TweetPhotoReturnTypes)returnType;
-(NSData*)getPhotos:(long long)userId ind:(int)ind ps:(int)ps sf:(TweetPhotoSortFilters)sf tags:(NSString*)tags sort:(TweetPhotoSorts)sort size:(TweetPhotoSizes)size returnType:(TweetPhotoReturnTypes)returnType;
-(NSData*)getNext:(long long)userId photoId:(long long)photoId returnType:(TweetPhotoReturnTypes)returnType;
-(NSData*)getPrevious:(long long)userId photoId:(long long)photoId returnType:(TweetPhotoReturnTypes)returnType;

// Get User Profile
-(NSData*)getUserProfileById:(long long)userId returnType:(TweetPhotoReturnTypes)returnType;
-(NSData*)getUserProfileByName:(NSString*)userName returnType:(TweetPhotoReturnTypes)returnType;

// Get Photo Metadata
-(NSData*)getPhotoMetaData:(long long)photoId returnType:(TweetPhotoPhotoReturnTypes)returnType;

// Get Social (Public)
-(NSData*)getSocial:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort returnType:(TweetPhotoSocialReturnTypes)returnType;

// Get Social (User Id)
-(NSData*)getSocial:(long long)userid ps:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort returnType:(TweetPhotoSocialReturnTypes)returnType;

// Get User Settings
-(NSData*)getUserSettings:(long long)userId returnType:(TweetPhotoSettingsReturnTypes)returnType;

// Settings
-(NSData*)setDoNotTweetFavoritePhoto:(long long)userId fave:(BOOL)fave;
-(NSData*)setHideViewingPatterns:(long long)userId hideView:(BOOL)hideView;
-(NSData*)setHideVotes:(long long)userId hideVote:(BOOL)hideVote;
-(NSData*)setMapType:(long long)userId mapType:(int)mapType;
-(NSData*)setPin:(long long)userId pin:(long long)pin;
-(NSData*)setShortenUrl:(long long)userId shorten:(BOOL)shorten;

// Delete / Set Location
-(NSData*)deleteLocation:(long long)photoId returnType:(TweetPhotoLocationReturnTypes)returnType;
-(NSData*)setLocation:(long long)photoId lat:(float)lat lon:(float)lon returnType:(TweetPhotoLocationReturnTypes)returnType;

// API Sign In
-(NSData*)apiSignIn:(TweetPhotoSignInReturnTypes)returnType;

// Upload
-(NSData *)upload:(NSData*)photo comment:(NSString*)message tags:(NSString*)tags latitude:(float)latitude longitude:(float)longitude returnType:(TweetPhotoUploadReturnTypes)returnType;

// Set Photo View
-(NSInteger)photoView:(long long)userId photoId:(long long)photoId;

// Vote thumbs up / thumbs down
-(NSData*)vote:(long long)photoId voteType:(TweetPhotoVoteTypes)voteType returnType:(TweetPhotoVoteReturnTypes)returnType;

// Check to see if a user has voted for a photo
-(NSData*)hasVoted:(long long)userId photoId:(long long)photoId returnType:(TweetPhotoHasVotedReturnTypes)returnType;

// Sign In to TweetPhoto
-(Profile *)signIn;

// User Profile By ID
-(Profile *)userProfileById:(long long)userId;

// User Profile By Name
-(Profile *)userProfileByName:(NSString *)userName;

// Returns User Settings
-(Settings *)userSettings:(long long)userId;

// User Has Voted
-(VoteStatus*)userHasVoted:(long long)userId photoId:(long long)photoId;

// Returns Favorites
-(Favorites*)favorites:(long long)userId;
-(Favorites*)favorites:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort;

// Returns Photos
-(Photos*)photos;
-(Photos*)photos:(long long)userId;
-(Photos*)photos:(long long)userId ind:(int)ind ps:(int)ps sf:(TweetPhotoSortFilters)sf tags:(NSString*)tags sort:(TweetPhotoSorts)sort size:(TweetPhotoSizes)size;
-(Photo*)photoMetaData:(long long)photoId;
-(Photo*)previous:(long long)userId photoId:(long long)photoId;
-(Photo*)next:(long long)userId photoId:(long long)photoId;
-(Photos*)leaderboard:(TweetPhotoLeaderboardTypes)leaderboardType;

// Returns Profiles of Friends
-(Profiles*)friends:(long long)userId;
-(Profiles*)friends:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort;

// Returns Comments
-(Comments*)comments:(long long)userId;
-(Comments*)comments:(long long)userId ind:(int)ind ps:(int)ps sortType:(TweetPhotoSorts)sort;
-(Comments*)photoComments:(long long)photoId;
-(Comments*)photoComments:(long long)photoId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort;
-(Comments*)userComments:(long long)userId;
-(Comments*)userComments:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort;

// Social Feed (Public)
-(SocialFeed*)social:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort;

// Social Feed (User Id)
-(SocialFeed*)social:(long long)userId ps:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort;

// Photo Upload
-(TweetPhotoResponse*)photoUpload:(NSData*)photo comment:(NSString*)message tags:(NSString*)tags latitude:(float)latitude longitude:(float)longitude;

// Helper functions that do the XML serialization heavy lifting
-(Comments*)packageComments:(NSString*)dataStr;
-(Favorites*)packageFavorites:(NSString*)dataStr;
-(Photo*)packagePhoto:(NSString*)dataStr;
-(Photos*)packagePhotos:(NSString*)dataStr;
-(Profile*)packageProfile:(NSString*)dataStr;
-(Profiles*)packageProfiles:(NSString*)dataStr;
-(TweetPhotoResponse*)packageResponse:(NSString*)dataStr;
-(Settings*)packageSettings:(NSString*)dataStr;
-(SocialFeed*)packageSocialFeed:(NSString*)dataStr;
-(VoteStatus*)packageVoteStatus:(NSString*)dataStr;

@end

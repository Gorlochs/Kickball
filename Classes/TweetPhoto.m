//
//  TweetPhoto.m
//  TPAPITest
//
//  Created by David J. Hinson on 1/15/10.
//  Copyright 2010 TweetPhoto, Inc. All rights reserved.
//
//	Objective-C Class Implementation for the TweetPhoto API, as specified here: http://groups.google.com/group/tweetphoto/web

#import "TweetPhoto.h"

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3)
	{
		unsigned long int sr = 0;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
		{
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte)
		{
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	
	return 0;
	
}

@implementation TweetPhoto

@synthesize identityToken  = _identityToken;
@synthesize identitySecret = _identitySecret;
@synthesize apiKey         = _apiKey;
@synthesize serviceName    = _serviceName;
@synthesize isoAuth        = _isoAuth;
@synthesize statusCode     = _statusCode;
@synthesize headerFields   = _headerFields;

// Basic Init
-(id)init {
	if (self=[super init]) {
		}
	
	return self;
}

// Init with Setup
-(id)initWithSetup:(NSString*)identityToken identitySecret:(NSString*)identitySecret apiKey:(NSString*)apiKey serviceName:(NSString*)serviceName isoAuth:(BOOL)isoAuth {
	if (self = [super init]) {
		self.identityToken  = identityToken;
		self.identitySecret = identitySecret;
		self.apiKey         = apiKey;
		self.serviceName    = serviceName;
		self.isoAuth        = isoAuth;
		}
	return self;
}

// Post a comment to a photo
-(NSData *)comment:(long long)userId photoId:(long long)photoId comment:(NSString*)comment returnType:(TweetPhotoCommentReturnTypes)returnType {
		
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/comments/%qi", returnType==TweetPhotoCommentReturnTypeJSON?@"json/":@"", userId, photoId];
		
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData* formData = [comment dataUsingEncoding:NSUTF8StringEncoding];
	NSInteger dataLength = [formData length];
	NSString* dataLengthStr = [NSString stringWithFormat:@"%d", dataLength];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	[theRequest addValue:@"True"                                                              forHTTPHeaderField:@"TPPOST"];
	[theRequest addValue:dataLengthStr                                                        forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)formData];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Delete a comment from a photo
-(NSInteger)commentDelete:(long long)userId photoId:(long long)photoId commentId:(long long)commentId {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/comments/%qi/%qi", userId, photoId, commentId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"DELETE"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
		
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	[theRequest addValue:@"True"                                                              forHTTPHeaderField:@"TPPOST"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return self.statusCode;
}

// Delete Photo
-(NSData*)deletePhoto:(long long)photoId returnType:(TweetPhotoDeletePhotoReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi", returnType==TweetPhotoDeletePhotoReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"DELETE"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Add Favorite
-(NSInteger)favoriteAdd:(long long)userId photoId:(long long)photoId {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/favorites/%qi", userId, photoId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];

	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return self.statusCode;
}

// Delete Favorite
-(NSInteger)favoriteDelete:(long long)userId photoId:(long long)photoId {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/favorites/%qi", userId, photoId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"DELETE"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return self.statusCode;
}

// Get All Photo Comments for a User
-(NSData*)getComments:(long long)userId returnType:(TweetPhotoCommentsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/photos/comments", returnType==TweetPhotoCommentsReturnTypeJSON?@"json/":@"", userId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get All Photo Comments for a User
-(NSData*)getComments:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoCommentsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/photos/comments?ps=%d&ind=%d&sort=%@", returnType==TweetPhotoCommentsReturnTypeJSON?@"json/":@"", userId, ps, ind, sort==TweetPhotoSortAsc?@"asc":@"desc"];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Photo Comments
-(NSData*)getPhotoComments:(long long)photoId returnType:(TweetPhotoCommentsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/comments", returnType==TweetPhotoCommentsReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Photo Comments
-(NSData*)getPhotoComments:(long long)photoId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoCommentsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/comments?ind=%d&ps=%d&sort=%@", returnType==TweetPhotoCommentsReturnTypeJSON?@"json/":@"", photoId, ind, ps, sort==TweetPhotoSortAsc?@"asc":@"desc"];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get User Comments
-(NSData*)getUserComments:(long long)userId returnType:(TweetPhotoCommentsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/comments", returnType==TweetPhotoCommentsReturnTypeJSON?@"json/":@"", userId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get User Comments
-(NSData*)getUserComments:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoCommentsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/comments?ind=%d&ps=%d&sort=%@", returnType==TweetPhotoCommentsReturnTypeJSON?@"json/":@"", userId, ind, ps, TweetPhotoSortAsc==sort?@"asc":@"desc"];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Favorites
-(NSData*)getFavorites:(long long)userId returnType:(TweetPhotoFavoritesReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/favorites", returnType==TweetPhotoFavoritesReturnTypeJSON?@"json/":@"", userId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Favorites
-(NSData*)getFavorites:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoFavoritesReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/favorites?ind=%d&ps=%d&sort=%@", returnType==TweetPhotoFavoritesReturnTypeJSON?@"json/":@"", userId, ind, ps, sort==TweetPhotoSortAsc?@"asc":@"desc"];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Feeds
-(NSData*)getFeed:(NSString*)userName feedType:(TweetPhotoFeedTypes)feedType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%@/photos", feedType==TweetPhotoFeedTypeATOM?@"atom/":@"rss/", userName];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Friends
-(NSData*)getFriends:(long long)userId returnType:(TweetPhotoFriendsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/friends", returnType==TweetPhotoFriendsReturnTypeJSON?@"json/":@"", userId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Friends
-(NSData*)getFriends:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort returnType:(TweetPhotoFriendsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/friends?ind=%d&ps=%d&sort=%@", returnType==TweetPhotoFriendsReturnTypeJSON?@"json/":@"", userId, ind, ps, sort==TweetPhotoSortAsc?@"asc":@"desc"];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Leaderboard by type
-(NSData*)getLeaderboard:(TweetPhotoLeaderboardTypes)leaderboardType returnType:(TweetPhotoLeaderboardReturnTypes)returnType {
	
	NSString * baseUrl;
	switch (returnType) {
		case TweetPhotoReturnTypeJSON:
			baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/json/leaderboard/uploadedtoday/";
			break;
		default:
		case TweetPhotoReturnTypeXML:
			baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/leaderboard/uploadedtoday/";
			break;
	}
	
	NSString * url;     
	switch (leaderboardType) {
		case TweetPhotoLeaderboardTypeCommented:			
			url = [NSString stringWithFormat:@"%@/commented", baseUrl];
			break;
		case TweetPhotoLeaderboardTypeVoted:			
			url = [NSString stringWithFormat:@"%@/voted", baseUrl];
			break;
		case TweetPhotoLeaderboardTypeViewed:			
		default:
			url = [NSString stringWithFormat:@"%@/viewed", baseUrl];
			break;
		}
	
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
}

// Get Next
-(NSData*)getNext:(long long)commentIduserId photoId:(long long)photoId returnType:(TweetPhotoReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/next", returnType==TweetPhotoReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Previous
-(NSData*)getPrevious:(long long)commentIduserId photoId:(long long)photoId returnType:(TweetPhotoReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/previous", returnType==TweetPhotoReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Photos for User
-(NSData*)getPhotos:(long long)userId returnType:(TweetPhotoReturnTypes)returnType {
	NSString * baseUrl;
	switch (returnType) {
		case TweetPhotoReturnTypeATOM:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/atom/users/%qi/photos", userId];
			break;
		case TweetPhotoReturnTypeJSON:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/json/users/%qi/photos", userId];
			break;
		case TweetPhotoReturnTypeRSS:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/rss/users/%qi/photos", userId];
			break;
		case TweetPhotoReturnTypeXML:
		default:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/photos", userId];
			break;
	}
	
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:baseUrl]];
}

// Get Photos Parameterized
-(NSData*)getPhotos:(long long)userId ind:(int)ind ps:(int)ps sf:(TweetPhotoSortFilters)sf tags:(NSString*)tags sort:(TweetPhotoSorts)sort size:(TweetPhotoSizes)size returnType:(TweetPhotoReturnTypes)returnType {
	
	NSString * baseUrl;
	NSString * sortFilterStr;
	switch (sf) {
		case TweetPhotoSortFilterComments:
			sortFilterStr = @"comments";
			break;
		case TweetPhotoSortFilterDate:
			sortFilterStr = @"date";
			break;
		case TweetPhotoSortFilterViews:
		default:
			sortFilterStr = @"views";
			break;
		}
	
	NSString * sortStr;
	switch (sort) {
		case TweetPhotoSortDesc:
			sortStr = @"desc";
			break;
		case TweetPhotoSortAsc:
		default:
			sortStr = @"asc";
			break;
		}
	
	NSString * sizeStr;
	switch (size) {
		case TweetPhotoSizeAll:
			sizeStr = @"all";
			break;
		case TweetPhotoSizeBig:
			sizeStr = @"big";
			break;
		case TweetPhotoSizeMedium:
			sizeStr = @"medium";
			break;
		case TweetPhotoSizeThumbnail:
		default:
			sizeStr = @"thumbnail";
			break;
	}
	
	switch (returnType) {
		case TweetPhotoReturnTypeATOM:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/atom/users/%qi/photos?ind=%d&ps=%d&sf=%@&sort=%@&size=%@", userId, ind, ps, sortFilterStr, sortStr, sizeStr];
			break;
		case TweetPhotoReturnTypeJSON:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/json/users/%qi/photos?ind=%d&ps=%d&sf=%@&sort=%@&size=%@", userId, ind, ps, sortFilterStr, sortStr, sizeStr];
			break;
		case TweetPhotoReturnTypeRSS:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/rss/users/%qi/photos?ind=%d&ps=%d&sf=%@&sort=%@&size=%@", userId, ind, ps, sortFilterStr, sortStr, sizeStr];
			break;
		case TweetPhotoReturnTypeXML:
		default:
			baseUrl = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/photos?ind=%d&ps=%d&sf=%@&sort=%@&size=%@", userId, ind, ps, sortFilterStr, sortStr, sizeStr];
			break;
		}
	
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:baseUrl]];
}

// Get Photos
-(NSData*)getPhotos:(TweetPhotoReturnTypes)returnType {
	NSString * baseUrl;
	switch (returnType) {
		case TweetPhotoReturnTypeATOM:
			baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/atom/photos";
			break;
		case TweetPhotoReturnTypeJSON:
			baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/json/photos";
			break;
		case TweetPhotoReturnTypeRSS:
			baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/rss/photos";
			break;
		case TweetPhotoReturnTypeXML:
		default:
			baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/photos";
			break;
		}
	
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:baseUrl]];
}

// Get Photo Meta Data
-(NSData*)getPhotoMetaData:(long long)photoId returnType:(TweetPhotoPhotoReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi", returnType==TweetPhotoVoteReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get Social
-(NSData*)getSocial:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort returnType:(TweetPhotoSocialReturnTypes)returnType {
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@socialfeed?ps=%d&ind=%d&sort=%@", returnType==TweetPhotoSocialReturnTypeJSON?@"json/":@"", ps, ind, sort==TweetPhotoSortAsc?@"asc":@"desc"];
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
}

// Get Social By User
-(NSData*)getSocial:(long long)userid ps:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort returnType:(TweetPhotoSocialReturnTypes)returnType {
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/feed?ps=%d&ind=%d&sort=desc", returnType==TweetPhotoSocialReturnTypeJSON?@"json/":@"", userid, ps, ind, sort==TweetPhotoSortAsc?@"asc":@"desc"];
	return [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
}

// Get Profile by User ID
-(NSData*)getUserProfileById:(long long)userId returnType:(TweetPhotoReturnTypes)returnType {
	switch (returnType) {
		case TweetPhotoReturnTypeJSON:
			return [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/json/users/%qi", userId]]];
			break;
		case TweetPhotoReturnTypeXML:
		default:
			return [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi", userId]]];
			break;
		}
	
	return nil;
}

// Get Profile by User Name
-(NSData*)getUserProfileByName:(NSString*)userName returnType:(TweetPhotoReturnTypes)returnType {
	switch (returnType) {
		case TweetPhotoReturnTypeJSON:
			return [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/json/users/%@", userName]]];
			break;
		case TweetPhotoReturnTypeXML:
		default:
			return [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%@", userName]]];
			break;
		}
	
	return nil;
}

// Get User Settings
-(NSData*)getUserSettings:(long long)userId returnType:(TweetPhotoSettingsReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/settings", returnType==TweetPhotoVoteReturnTypeJSON?@"json/":@"", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set Photo as Viewed
-(NSInteger)photoView:(long long)userId photoId:(long long)photoId {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/views/%qi", userId, photoId];
	
	NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return self.statusCode;
}

// Delete Location
-(NSData*)deleteLocation:(long long)photoId returnType:(TweetPhotoLocationReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/location", returnType==TweetPhotoLocationReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"DELETE"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set Location
-(NSData*)setLocation:(long long)photoId lat:(float)lat lon:(float)lon returnType:(TweetPhotoLocationReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/location", returnType==TweetPhotoLocationReturnTypeJSON?@"json/":@"", photoId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData *pinData = [[NSString stringWithFormat:@"%.6f,%.6f", lat, lon] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set map type
-(NSData*)setMapType:(long long)userId mapType:(int)mapType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/settings/maptype", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData *pinData = [[NSString stringWithFormat:@"%d", mapType] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set pin
-(NSData*)setPin:(long long)userId pin:(long long)pin {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/settings/pin", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData *pinData = [[NSString stringWithFormat:@"%d", pin] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set Shorten Url
-(NSData*)setShortenUrl:(long long)userId shorten:(BOOL)shorten {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/settings/shortenurl", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	//NSData *pinData = [[NSString stringWithFormat:@"%@", shorten ? @"true" : @"false"] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *pinData = [[NSString stringWithFormat:@"%d", shorten ? 1 : 0] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set Do Not Tweet Favorite Photo
-(NSData*)setDoNotTweetFavoritePhoto:(long long)userId fave:(BOOL)fave {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/settings/donottweetfavoritephoto", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData *pinData = [[NSString stringWithFormat:@"%d", fave ? 1 : 0] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set Hide Viewing Patterns
-(NSData*)setHideViewingPatterns:(long long)userId hideView:(BOOL)hideView {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/settings/hideviewingpatterns", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData *pinData = [[NSString stringWithFormat:@"%d", hideView] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Set Hide Votes
-(NSData*)setHideVotes:(long long)userId hideVote:(BOOL)hideVote {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi/settings/hidevotes", userId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSData *pinData = [[NSString stringWithFormat:@"%d", hideVote] dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	[theRequest addValue:[NSString stringWithFormat:@"%d",[pinData length]]                   forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:pinData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Get linked services
-(NSData*)getLinkedServices {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/profiles"];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:@"application/x-www-form-urlencoded"                                 forHTTPHeaderField: @"Content-Type"];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Link a service
-(NSData*)linkService:(NSString*)apiKey serviceName:(NSString*)serviceName identityToken:(NSString*)identityToken identitySecret:(NSString*)identitySecret {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/link"];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	NSString * xmlString = [NSString 
							stringWithFormat:@"<LinkedProfile xmlns=\"http://tweetphotoapi.com\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"><APIKey>%@</APIKey><IdentitySecret>%@</IdentitySecret><IdentityToken>%@</IdentityToken><Service>%@</Service></LinkedProfile>",
							apiKey, identitySecret, identityToken, serviceName];
	NSData * xmlData	 = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	[theRequest addValue:[NSString stringWithFormat:@"%d",[xmlData length]]					  forHTTPHeaderField: @"Content-Length"];   
	[theRequest setHTTPBody:xmlData];    
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Unlink a service
-(NSData*)unlinkService:(NSString*)serviceName {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/unlink/%@", serviceName];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"DELETE"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// API Sign In
-(NSData*)apiSignIn:(TweetPhotoSignInReturnTypes)returnType {
	NSString * baseUrl;
	switch (returnType) {
		case TweetPhotoSignInReturnTypeJSON:
			if (self.isoAuth) {
				baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/json/oauthsignin";
				}
			else {
				if ([self.serviceName isEqualToString:@"Facebook"]) {
					baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/json/facebooksignin";
				} else {
					baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/json/signin";
					}
				}
			break;
		case TweetPhotoSignInReturnTypeXML:
		default:
			if (self.isoAuth) {
				baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/oauthsignin";
				}
			else {
				if ([self.serviceName isEqualToString:@"Facebook"]) {
					baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/json/facebooksignin";
				} else {
					baseUrl = @"http://tweetphotoapi.com/api/tpapi.svc/signin";
					}
				}
			break;
		}
	
	NSMutableURLRequest* theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Upload Photo (Upload Two Method)
-(NSData *)upload:(NSData*)photo comment:(NSString*)message tags:(NSString*)tags latitude:(float)latitude longitude:(float)longitude returnType:(TweetPhotoUploadReturnTypes)returnType {
	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@upload2",returnType==TweetPhotoUploadReturnTypeJSON?@"json/":@""]];
	
	NSMutableURLRequest* theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"POST"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	
	// Base64 Encode username and password
	memset(encodeArray,'\0', sizeof(encodeArray));
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);		
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	// Base64 Encode message
	memset(encodeArray,'\0', sizeof(encodeArray));
	encodeData = [message dataUsingEncoding:NSUTF8StringEncoding];
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);		
	NSString *base64Message	= [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding];	
	
	// Base64 Encode tags
	memset(encodeArray,'\0', sizeof(encodeArray));
	encodeData = [tags dataUsingEncoding:NSUTF8StringEncoding];
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);		
	NSString *base64Tags = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding];	
	
	[theRequest addValue:self.serviceName													forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth?@"True":@"False"]	forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey														forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:@"image/jpg"														forHTTPHeaderField:@"TPMIMETYPE"];
	[theRequest addValue:@"True"															forHTTPHeaderField:@"TPPOST"];
	
	if (latitude!=0.0 && longitude!=0.0) {
		[theRequest addValue:[NSString stringWithFormat:@"%.6f", latitude]				forHTTPHeaderField:@"TPLAT"];
		[theRequest addValue:[NSString stringWithFormat:@"%.6f", longitude]				forHTTPHeaderField:@"TPLONG"];
		}
	
	[theRequest addValue:authorizationString											forHTTPHeaderField:@"Authorization"];
	[theRequest addValue:@"True"														forHTTPHeaderField:@"TPUTF8"];
	[theRequest addValue:base64Message													forHTTPHeaderField:@"TPMSG"];
	if (tags!=nil && [tags length]>0) {
		[theRequest addValue:base64Tags													forHTTPHeaderField:@"TPTAGS"];
		}
	[theRequest addValue:[NSString stringWithFormat:@"%d",[photo length]]				forHTTPHeaderField: @"Content-Length"];   
	
	[theRequest setHTTPBody:photo];    

	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Vote Up/Down
-(NSData*)vote:(long long)photoId voteType:(TweetPhotoVoteTypes)voteType returnType:(TweetPhotoVoteReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@photos/%qi/%@", returnType==TweetPhotoVoteReturnTypeJSON?@"json/":@"", photoId, (voteType==TweetPhotoVoteTypeThumbsUp)?@"thumbsup":@"thumbsdown"];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"PUT"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

-(NSData*)hasVoted:(long long)userId photoId:(long long)photoId returnType:(TweetPhotoHasVotedReturnTypes)returnType {
	
	NSString *url = [NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/%@users/%qi/votes/%qi", returnType==TweetPhotoVoteReturnTypeJSON?@"json/":@"", userId, photoId];
	
	NSMutableURLRequest *theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];	
	
	[theRequest setHTTPMethod:@"GET"];
	
	NSData *encodeData = [[NSString stringWithFormat:@"%@:%@", self.identityToken, self.identitySecret] dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray,'\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);	
	
	NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding]; 
	NSString *authorizationString = [NSString stringWithFormat:@"Basic %@", dataStr];
	
	[theRequest addValue:self.serviceName                                                     forHTTPHeaderField:@"TPSERVICE"];
	[theRequest addValue:[NSString stringWithFormat:@"%@", self.isoAuth ? @"True" : @"False"] forHTTPHeaderField:@"TPISOAUTH"];
	[theRequest addValue:self.apiKey                                                          forHTTPHeaderField:@"TPAPIKEY"];
	[theRequest addValue:authorizationString                                                  forHTTPHeaderField:@"Authorization"];
	
	NSError * nsError;
	NSHTTPURLResponse * urlResponse;
	
	NSData * data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&urlResponse error:&nsError];
	
	self.headerFields = [urlResponse allHeaderFields];
	self.statusCode   = [urlResponse statusCode];
	
	return data;
}

// Favorites By User Id
-(Favorites*)favorites:(long long)userId {
	return [self packageFavorites:[[[NSString alloc] initWithData:[self getFavorites:userId returnType:TweetPhotoFavoritesReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Favorites By Parms
-(Favorites*)favorites:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort {
	return [self packageFavorites:[[[NSString alloc] initWithData:[self getFavorites:userId ind:ind ps:ps sort:sort returnType:TweetPhotoFavoritesReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Photo Comments
-(Comments*)photoComments:(long long)photoId {
	return [self packageComments:[[[NSString alloc] initWithData:[self getPhotoComments:photoId returnType:TweetPhotoCommentReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Photo Comments
-(Comments*)photoComments:(long long)photoId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort {
	return [self packageComments:[[[NSString alloc] initWithData:[self getPhotoComments:photoId ind:ind ps:ps sort:sort returnType:TweetPhotoCommentReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// All Comments for a User
-(Comments*)comments:(long long)userId {
	return [self packageComments:[[[NSString alloc] initWithData:[self getComments:userId returnType:TweetPhotoCommentReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// All Comments for a User
-(Comments*)comments:(long long)userId ind:(int)ind ps:(int)ps sortType:(TweetPhotoSorts)sort {
	return [self packageComments:[[[NSString alloc] initWithData:[self getComments:userId ind:ind ps:ps sort:sort returnType:TweetPhotoCommentReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// User Comments
-(Comments*)userComments:(long long)userId {
	return [self packageComments:[[[NSString alloc] initWithData:[self getUserComments:userId returnType:TweetPhotoCommentReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// User Comments
-(Comments*)userComments:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort {
	return [self packageComments:[[[NSString alloc] initWithData:[self getUserComments:userId ind:ind ps:ps sort:sort returnType:TweetPhotoCommentReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Photos
-(Photos*)photos {
	NSString * dataStr = [[[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://tweetphotoapi.com/api/tpapi.svc/photos"]] encoding:NSUTF8StringEncoding] autorelease];
	return [self packagePhotos:dataStr];
}

// Photos By User ID
-(Photos*)photos:(long long)userId {
	return [self packagePhotos:[[[NSString alloc] initWithData:[self getPhotos:userId returnType:TweetPhotoPhotoReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Photos with Parms
-(Photos*)photos:(long long)userId ind:(int)ind ps:(int)ps sf:(TweetPhotoSortFilters)sf tags:(NSString*)tags sort:(TweetPhotoSorts)sort size:(TweetPhotoSizes)size {
	return [self packagePhotos:[[[NSString alloc] initWithData:[self getPhotos:userId ind:ind ps:ps sf:sf tags:tags sort:sort size:size returnType:TweetPhotoPhotoReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Photo Metadata
-(Photo*)photoMetaData:(long long)photoId {
	return [self packagePhoto:[[[NSString alloc] initWithData:[self getPhotoMetaData:photoId returnType:TweetPhotoPhotoReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Previous Photo
-(Photo*)previous:(long long)userId photoId:(long long)photoId {
	return [self packagePhoto:[[[NSString alloc] initWithData:[self getPrevious:userId photoId:photoId returnType:TweetPhotoPhotoReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Next Photo
-(Photo*)next:(long long)userId photoId:(long long)photoId {
	return [self packagePhoto:[[[NSString alloc] initWithData:[self getNext:userId photoId:photoId returnType:TweetPhotoPhotoReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// leaderboard
-(Photos*)leaderboard:(TweetPhotoLeaderboardTypes)leaderboardType {
	return [self packagePhotos:[[[NSString alloc] initWithData:[self getLeaderboard:leaderboardType returnType:TweetPhotoLeaderboardReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Friends by User Id
-(Profiles*)friends:(long long)userId {
	return [self packageProfiles:[[[NSString alloc] initWithData:[self getFriends:userId returnType:TweetPhotoFriendsReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Friends by Parnms
-(Profiles*)friends:(long long)userId ind:(int)ind ps:(int)ps sort:(TweetPhotoSorts)sort {
	return [self packageProfiles:[[[NSString alloc] initWithData:[self getFriends:userId ind:ind ps:ps sort:sort returnType:TweetPhotoFriendsReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// User has voted status
-(VoteStatus*)userHasVoted:(long long)userId photoId:(long long)photoId {
	return [self packageVoteStatus:[[[NSString alloc] initWithData:[self hasVoted:userId photoId:photoId returnType:TweetPhotoHasVotedReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Photo Upload
-(TweetPhotoResponse*)photoUpload:(NSData*)photo comment:(NSString*)message tags:(NSString*)tags latitude:(float)latitude longitude:(float)longitude {
	return [self packageResponse:[[[NSString alloc] initWithData:[self upload:photo comment:message tags:tags latitude:latitude longitude:longitude returnType:TweetPhotoUploadReturnTypeXML]  encoding:NSUTF8StringEncoding] autorelease]];
}

// Social Feed (Public)
-(SocialFeed*)social:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort  {
	return [self packageSocialFeed:[[[NSString alloc] initWithData:[self getSocial:ps ind:ind sort:sort returnType:TweetPhotoSocialReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Social Feed (User Id)
-(SocialFeed*)social:(long long)userId ps:(int)ps ind:(int)ind sort:(TweetPhotoSorts)sort  {
	return [self packageSocialFeed:[[[NSString alloc] initWithData:[self getSocial:userId ps:ps ind:ind sort:sort returnType:TweetPhotoSocialReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease]];
}

// Profile by User ID
-(Profile *)userProfileById:(long long)userId {
	return [self packageProfile:[[[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%qi", userId]]] encoding:NSUTF8StringEncoding] autorelease]];
}

// User Profile by User Name
-(Profile *)userProfileByName:(NSString *)userName {
	return [self packageProfile:[[[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://tweetphotoapi.com/api/tpapi.svc/users/%@", userName]]] encoding:NSUTF8StringEncoding] autorelease]];
}

// Get linked services
-(Profiles *)linkedServices {
	return [self packageProfiles:[[[NSString alloc] initWithData:[self getLinkedServices] encoding:NSUTF8StringEncoding] autorelease]];
}

// User Settings
-(Settings *)userSettings:(long long)userId {
	
	NSString * dataStr    = [[NSString alloc] initWithData:[self getUserSettings:userId returnType:TweetPhotoSettingsReturnTypeXML] encoding:NSUTF8StringEncoding];

	if (self.statusCode==200) {
		return [self packageSettings:dataStr];
		}
	
	return nil;
}

-(NSString*)xmlDecode:(NSString*)target {
	NSMutableString * work = [[target copy] autorelease];
	
	work = (NSMutableString*)[work stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	work = (NSMutableString*)[work stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	work = (NSMutableString*)[work stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	work = (NSMutableString*)[work stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
	work = (NSMutableString*)[work stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
	
	return work;
}

-(NSDate*)dateFromISO8601:(NSString*)str {
	static NSDateFormatter* sISO8601 = nil;
	
	if (str == nil) {
		NSDate * today = [[[NSDate alloc] init] autorelease];
		return today;
	}
	
	if (!sISO8601) {
		sISO8601 = [[NSDateFormatter alloc] init];
		// [sISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];   
		[sISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];   
	}
	return [sISO8601 dateFromString:[str substringToIndex:[str length]-2]];
}

-(NSString*)describeEventTimeStamp:(NSDate *)stamp {
	
	NSDate * stopDate    = [[NSDate alloc] init];
	NSTimeInterval start = [stamp timeIntervalSinceReferenceDate];
	NSTimeInterval stop  = [stopDate timeIntervalSinceReferenceDate];
	NSTimeZone *zone     = [NSTimeZone defaultTimeZone];
	int offset           = [zone secondsFromGMT];
	start                += offset;
	long diffInt         = (stop - start);
	[stopDate release];
	
	// NSLog(@"Diff: %d, start: %f, stop: %f ", stopDate, diffInt, start, stop);
	
	if (diffInt == 1)       {return @"just now.";}
	if (diffInt < 10)       {return @"a few seconds ago";}
	if (diffInt < 60)       {return [NSString stringWithFormat:@"%ld seconds ago", diffInt];}
	if (diffInt < 3600)     {return [NSString stringWithFormat:@"%ld minute%@ ago", diffInt / 60, (diffInt/60)==1?@"":@"s"];}
	if (diffInt < 7200)     {return @"1 hour ago";}	
	if (diffInt < 86400)    {return [NSString stringWithFormat:@"%ld hour%@ ago", diffInt / (60 * 60), (diffInt / (60 * 60)==1)?@"":@"s"];}
	
	if (abs(diffInt) < 2592000)  {
		if (((diffInt / (60 * 60 * 24))+1)>6) {
			return [NSString stringWithFormat:@"%ld week%@ ago", (diffInt / (60 * 60 * 24) + 1)/7, ((diffInt / (60 * 60 * 24) + 1)/7)==1?@"":@"s"];
		}
		else {
			return[NSString stringWithFormat:@"%ld day%@ ago", (diffInt / (60 * 60 * 24)), (diffInt / (60 * 60 * 24))==1?@"":@"s"];
		}
	}
	
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"MM/dd/yyyy"];
	return [NSString stringWithFormat:@"on %@", [format stringFromDate:stamp]];
	
	return nil;
}

// Serialize photo from an XML string
-(Photo*)packagePhoto:(NSString*)dataStr {
	
	Element* root   = [Element parseXML: dataStr];
	NSArray* photos = [root selectElements: @"Photo"];
	
	Photo * tpImage = [[Photo alloc] init];
	
	for (Element* photo in photos) {
		NSArray * childElements = photo.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"BigImageUrl"]) {
				tpImage.bigImageURL = (NSMutableString*)element.contentsText;
				}
			if ([element.key isEqualToString:@"CommentCount"]) {
				tpImage.commentCount = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"DetailsUrl"]) {
				tpImage.detailsURL = (NSMutableString*)element.contentsText;
				}
			if ([element.key isEqualToString:@"GdAlias"]) {
				tpImage.gdAlias = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"Id"]) {
				tpImage.photoId = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"LargeImageUrl"]) {
				tpImage.largeImageURL = (NSMutableString*)element.contentsText;
				}
			if ([element.key isEqualToString:@"Location"]) {
				NSArray * locations     = element.childElements;
				tpImage.location = [[Location alloc] init];
				for (Element* location in locations) {
					if ([location.key isEqualToString:@"Latitude"]) {
						tpImage.location.latitude = [location.contentsText floatValue];
						}
					if ([location.key isEqualToString:@"Longitude"]) {
						tpImage.location.longitude = [location.contentsText floatValue];
						}
					}
				}
			if ([element.key isEqualToString:@"MediumImageUrl"]) {
				tpImage.mediumImageURL = (NSMutableString*)element.contentsText;
				}
			if ([element.key isEqualToString:@"Message"]) {
				tpImage.message = (NSMutableString*)[self xmlDecode:element.contentsText];
				}
			if ([element.key isEqualToString:@"Name"]) {
				tpImage.name = (NSMutableString*)[self xmlDecode:element.contentsText];
				}
			if ([element.key isEqualToString:@"Next"]) {
				tpImage.next = (NSMutableString*)[self xmlDecode:element.contentsText];
				}
			if ([element.key isEqualToString:@"Previous"]) {
				tpImage.previous = (NSMutableString*)[self xmlDecode:element.contentsText];
				}
			if ([element.key isEqualToString:@"LikedVotes"]) {
				tpImage.likedVotes = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"UnLikedVotes"]) {
				tpImage.unlikedVotes = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"ThumbnailUrl"]) {
				tpImage.thumbnailURL = (NSMutableString*)element.contentsText;
				}
			if ([element.key isEqualToString:@"TinyAlias"]) {
				tpImage.tinyAlias = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"UploadDate"]) {
				tpImage.uploadDate = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"UploadDateString"]) {
				tpImage.uploadDateString = (NSMutableString*)[NSString stringWithFormat:@"Uploaded %@", [self describeEventTimeStamp:[self dateFromISO8601:element.contentsText]]];
				}
			if ([element.key isEqualToString:@"UserId"]) {
				tpImage.userId = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"Views"]) {
				tpImage.views = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"PhotoComments"]) {
				Comments * comments = [self packageComments:[NSString stringWithFormat:@"<Comments>%@</Comments>", element.contentsSource]];
				tpImage.photoComments = comments;
				[comments release];
				}
			}
		}
	
	return tpImage;
}

// Serialize photo(s) from an XML string
-(Photos*)packagePhotos:(NSString*)dataStr {
	
	Photos * tpPhotos = [[[Photos alloc] init] autorelease];
	
	Element* root   = [Element parseXML: dataStr];
	NSArray* photos = [root selectElements: @"Photos"];
	
	for (Element* photo in photos) {
		NSArray * childElements = photo.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"Count"]) {				
				tpPhotos.count = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"StartIndex"]) {				
				tpPhotos.startIndex = [element.contentsText intValue];
				}

			if ([element.key isEqualToString:@"List"]) {				
				
				NSMutableArray *tmpArr ; 
				tmpArr = [[NSMutableArray alloc]init] ; 
				NSArray* pfs  = [root selectElements: @"Photo"];
				
				for (Element * p in pfs) {
					Photo * pf = [self packagePhoto:[NSString stringWithFormat:@"<Photo>%@</Photo>",p.contentsSource]];
					[tmpArr addObject:pf];
					[pf release];
					}
				
				tpPhotos.list = tmpArr;
				[tmpArr release];
				}
			}
		}

		return tpPhotos;
}

// Serialize profile from an XML string
-(Profile*)packageProfile:(NSString*)dataStr {
	Element* root             = [Element parseXML: dataStr];
	NSArray* profileElements  = [root selectElements: @"Profile"];
	
	Profile * pf              = [[Profile alloc] init];
	
	for (Element* profile in profileElements) {
		NSArray * childElements = profile.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"Id"]) {				
				pf.id = [element.contentsText intValue];
			}
			if ([element.key isEqualToString:@"Comments"]) {				
				pf.comments = element.contentsText;
			}
			if ([element.key isEqualToString:@"Description"]) {				
				pf.description = element.contentsText;
			}
			if ([element.key isEqualToString:@"Favorites"]) {				
				pf.favorites = element.contentsText;
			}
			if ([element.key isEqualToString:@"FirstName"]) {				
				pf.firstName = element.contentsText;
			}
			if ([element.key isEqualToString:@"Friends"]) {				
				pf.friends = element.contentsText;
			}
			if ([element.key isEqualToString:@"Homepage"]) {				
				pf.homepage = element.contentsText;
			}
			if ([element.key isEqualToString:@"MapTypeForProfile"]) {				
				pf.mapTypeForProfile = element.contentsText;
			}
			if ([element.key isEqualToString:@"Photos"]) {				
				pf.photos = element.contentsText;
			}
			if ([element.key isEqualToString:@"ProfileImage"]) {				
				pf.profileImage     = element.contentsText;
				// Grab the profile image data as well
				pf.profileImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pf.profileImage]];
			}
			if ([element.key isEqualToString:@"ScreenName"]) {				
				pf.screenName = element.contentsText;
			}
			if ([element.key isEqualToString:@"ServiceId"]) {				
				pf.serviceId = [element.contentsText intValue];
			}
			if ([element.key isEqualToString:@"Settings"]) {				
				pf.settings = element.contentsText;
			}
			if ([element.key isEqualToString:@"Views"]) {				
				pf.views = element.contentsText;
			}
		}
	}
	
	return pf;
}

// Serialize profile(s) from an XML string
-(Profiles*)packageProfiles:(NSString*)dataStr {
	
	Profiles * profiles = [[[Profiles alloc] init] autorelease];
	
	Element* root = [Element parseXML: dataStr];
	NSArray* pfs  = [root selectElements: @"Profiles"];
	
	for (Element* profileElement in pfs) {
		NSArray * childElements = profileElement.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"Count"]) {				
				profiles.count = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"StartIndex"]) {				
				profiles.startIndex = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"Filter"]) {				
				profiles.filter = element.contentsText;
				}
			if ([element.key isEqualToString:@"LinkedServices"]) {				
				profiles.linkedServices = element.contentsText;
				}
			
			if ([element.key isEqualToString:@"List"]) {				

				NSMutableArray *tmpArr ; 
				tmpArr = [[NSMutableArray alloc]init] ; 
				
				NSArray* pfs  = [root selectElements: @"Profile"];
				
				for (Element * p in pfs) {
					Profile * pf = [self packageProfile:[NSString stringWithFormat:@"<Profile>%@</Profile>",p.contentsSource]];
					[tmpArr addObject:pf];
					[pf release];
					}
				
				profiles.list = tmpArr;
				[tmpArr release];
				}
			}
		}
	
	return profiles;
}

// Serialize comment(s) from an XML string
-(Comments*)packageComments:(NSString*)dataStr {
	
	Comments * comments = [[[Comments alloc] init] autorelease];
	
	Element* root = [Element parseXML: dataStr];
	NSArray* cms  = [root selectElements: @"Comments"];
	
	for (Element * cmsElement in cms) {
		NSArray * childElements = cmsElement.childElements;
		
		for (Element * element in childElements) {
			for (Element* profileElement in cms) {
				
				if ([element.key isEqualToString:@"Count"]) {				
					comments.count = [element.contentsText intValue];
					}
				if ([element.key isEqualToString:@"StartIndex"]) {				
					comments.startIndex = [element.contentsText intValue];
					}
				if ([element.key isEqualToString:@"PhotoId"]) {				
					comments.photoId = [element.contentsText intValue];
					}
				
				if ([element.key isEqualToString:@"List"]) {	
					
					NSMutableArray *tmpArr ; 
					tmpArr = [[NSMutableArray alloc]init] ; 
				
					NSArray* com  = [root selectElements: @"Comment"];
					
					for (Element * comElement in com) {
						NSArray *  comKids = comElement.childElements;
						
						Comment * cm = [[Comment alloc] init];
		
						for (Element * comKid in comKids) {
							if ([comKid.key isEqualToString:@"Date"]) {				
								cm.date = [comKid.contentsText intValue];
								}
							if ([comKid.key isEqualToString:@"DateString"]) {				
								cm.dateString = comKid.contentsText;
								}
							if ([comKid.key isEqualToString:@"Id"]) {				
								cm.id = [comKid.contentsText intValue];
								}
							if ([comKid.key isEqualToString:@"ImageId"]) {				
								cm.imageId = [comKid.contentsText intValue];
								}
							if ([comKid.key isEqualToString:@"Message"]) {				
								cm.message = [self xmlDecode:[self xmlDecode:comKid.contentsText]];
								}
							if ([comKid.key isEqualToString:@"ProfileImage"]) {				
								cm.profileImage = [self xmlDecode:comKid.contentsText];
								}
							if ([comKid.key isEqualToString:@"ScreenName"]) {				
								cm.screenName = [self xmlDecode:comKid.contentsText];
								}
							if ([comKid.key isEqualToString:@"ProfileId"]) {				
								cm.profileId = [comKid.contentsText intValue];
								}
							}
							
						[tmpArr addObject:cm];
						[cm release];
						}
					
					comments.list = tmpArr;
					[tmpArr release];
					}
				}
			}
		}
	
	return comments;
}

// Serialize favorite(s) from an XML string
-(Favorites*)packageFavorites:(NSString*)dataStr {
	
	Favorites * favorites = [[[Favorites alloc] init] autorelease];
	
	Element* root = [Element parseXML: dataStr];
	NSArray* fav  = [root selectElements: @"Favorites"];
	
	for (Element * favElement in fav) {
		NSArray * childElements = favElement.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"Count"]) {				
				favorites.count = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"StartIndex"]) {				
				favorites.startIndex = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"List"]) {				
				
				NSMutableArray *tmpArr ; 
				tmpArr = [[NSMutableArray alloc]init] ; 
				
				NSArray* faves = [element selectElements: @"Favorite"];
				for (Element* fave in faves) {
					
					NSArray * faveKids = fave.childElements;
					
					Favorite * fv = [[Favorite alloc] init];
					
					for (Element * faveKid in faveKids) {
						
						if ([faveKid.key isEqualToString:@"FavoriteDate"]) {				
							fv.favoriteDate = [faveKid.contentsText intValue];
							}
						if ([faveKid.key isEqualToString:@"FavoriteDateString"]) {				
							fv.favoriteDateString = faveKid.contentsText;
							}
						if ([faveKid.key isEqualToString:@"ImageId"]) {				
							fv.imageId = [faveKid.contentsText intValue];
							}
						if ([faveKid.key isEqualToString:@"UserId"]) {				
							fv.userId = [faveKid.contentsText intValue];
							}
						if ([faveKid.key isEqualToString:@"Photo"]) {		
							fv.photo = [[self packagePhoto:[NSString stringWithFormat:@"<Photo>%@</Photo>", faveKid.contentsSource]] autorelease];
							}
						}
					
					[tmpArr addObject:fv];
					[fv release];
					}
				
				favorites.list = tmpArr;
				[tmpArr release];
				}
			}
		}
	
	return favorites;
}

// Serialize response from an XML string
-(TweetPhotoResponse*)packageResponse:(NSString*)dataStr {
	Element* root             = [Element parseXML: dataStr];
	NSArray* profileElements  = [root selectElements: @"TweetPhotoResponse"];
	
	TweetPhotoResponse * tr	  = [[[TweetPhotoResponse alloc] init] autorelease];
	
	for (Element* profile in profileElements) {
		NSArray * childElements = profile.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"Large"]) {				
				tr.large = element.contentsText;
				}
			if ([element.key isEqualToString:@"MediaId"]) {				
				tr.mediaId = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"MediaUrl"]) {				
				tr.mediaUrl = element.contentsText;
				}
			if ([element.key isEqualToString:@"Medium"]) {				
				tr.medium = element.contentsText;
				}
			if ([element.key isEqualToString:@"Original"]) {				
				tr.original = element.contentsText;
				}
			if ([element.key isEqualToString:@"PhotoId"]) {				
				tr.photoId = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"SessionKeyResponse"]) {				
				tr.sessionKeyResponse = element.contentsText;
				}
			if ([element.key isEqualToString:@"Status"]) {				
				tr.status = element.contentsText;
				}
			if ([element.key isEqualToString:@"Thumbnail"]) {				
				tr.thumbnail = element.contentsText;
				}
			if ([element.key isEqualToString:@"UserId"]) {				
				tr.userId = [element.contentsText intValue];
				}
			}
		}
	
	return tr;
}

// Serialize settings from an XML string
-(Settings*)packageSettings:(NSString*)dataStr {
	Element* root             = [Element parseXML: dataStr];
	NSArray* profileElements  = [root selectElements: @"ProfileSettings"];
	
	Settings * st             = [[[Settings alloc] init] autorelease];
	
	for (Element* profile in profileElements) {
		NSArray * childElements = profile.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"DoNotTweetFavoritePhoto"]) {				
				st.doNotTweetFavoritePhoto = [element.contentsText boolValue];
			}
			if ([element.key isEqualToString:@"Email"]) {				
				st.email = element.contentsText;
			}
			if ([element.key isEqualToString:@"HideViewingPatterns"]) {				
				st.hideViewingPatterns = [element.contentsText boolValue];
			}
			if ([element.key isEqualToString:@"HideVotes"]) {				
				st.hideVotes = [element.contentsText boolValue];
			}
			if ([element.key isEqualToString:@"MapType"]) {				
				st.mapType = element.contentsText;
			}
			if ([element.key isEqualToString:@"PIN"]) {				
				st.pin = [element.contentsText intValue];
			}
			if ([element.key isEqualToString:@"ShortenUrl"]) {				
				st.shortenUrl = [element.contentsText boolValue];
			}
		}
	}
	
	return st;
}

// Package the Social Feed
-(SocialFeed*)packageSocialFeed:(NSString*)dataStr {
	Element* root             = [Element parseXML: dataStr];
	NSArray* profileElements  = [root selectElements: @"SocialFeed"];
	
	SocialFeed * sf           = [[[SocialFeed alloc] init] autorelease];
	
	for (Element* profile in profileElements) {
		NSArray * childElements = profile.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"Filter"]) {				
				sf.filter = element.contentsText;
				}
			if ([element.key isEqualToString:@"Count"]) {				
				sf.count = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"StartIndex"]) {				
				sf.startIndex = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"List"]) {
				
				NSMutableArray *tmpArr ; 
				tmpArr = [[NSMutableArray alloc]init] ; 
				
				NSArray* events = [element selectElements: @"SocialFeedEvent"];
				for (Element* event in events) {
					
					NSArray * eventKids = event.childElements;
					
					SocialFeedEvent * sfe = [[SocialFeedEvent alloc] init];
										
					for (Element * kid in eventKids) {
						if ([kid.key isEqualToString:@"Content"]) {
							sfe.content = (NSMutableString*)[self xmlDecode:kid.contentsText];
							}
						if ([kid.key isEqualToString:@"Date"]) {
							sfe.date = [[TweetPhotoDate alloc] init];
						
							NSArray* dates = [kid selectElements: @"Date"];
							for (Element* date in dates) {
								NSArray * dateKids = date.childElements;
								for (Element* dateKid in dateKids) {
									if ([dateKid.key isEqualToString:@"UploadDate"]) {
										sfe.date.uploadDate = [dateKid.contentsText intValue];
										}
									if ([dateKid.key isEqualToString:@"UploadDateString"]) {
										sfe.date.uploadDateString = [NSString stringWithFormat:@"Uploaded %@", [self describeEventTimeStamp:[self dateFromISO8601:dateKid.contentsText]]];
										}
									}
								}
							}
						if ([kid.key isEqualToString:@"EventType"]) {
							sfe.eventType = kid.contentsText;
							}
						if ([kid.key isEqualToString:@"ImageThumbnail"]) {
							sfe.imageThumbnail = kid.contentsText;
							}
						if ([kid.key isEqualToString:@"PhotoId"]) {
							sfe.photoId = [kid.contentsText intValue];
							}
						if ([kid.key isEqualToString:@"User"]) {
							sfe.user = [[self packageProfile:[NSString stringWithFormat:@"<Profile>%@</Profile>", kid.contentsSource]] autorelease];
							}
						}
					
					[tmpArr addObject:sfe];
					[sfe release];					
					}
				
				sf.list = tmpArr;
				[tmpArr release];
				}
			}
		}
	
	return sf;
}

-(VoteStatus*)packageVoteStatus:(NSString*)dataStr {
	VoteStatus * vs			  = [[[VoteStatus alloc] init] autorelease];
	Element* root             = [Element parseXML: dataStr];
	NSArray* profileElements  = [root selectElements: @"VoteStatus"];
	
	for (Element* profile in profileElements) {
		NSArray * childElements = profile.childElements;
		
		for (Element * element in childElements) {
			if ([element.key isEqualToString:@"PhotoId"]) {				
				vs.photoId = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"UserId"]) {				
				vs.userId = [element.contentsText intValue];
				}
			if ([element.key isEqualToString:@"Status"]) {				
				vs.status = element.contentsText;
				}
			}
		}
			
	return vs;
}

// Sign In
-(Profile *)signIn {
	
	NSString * dataStr    = [[[NSString alloc] initWithData:[self apiSignIn:TweetPhotoSignInReturnTypeXML] encoding:NSUTF8StringEncoding] autorelease];

	if (self.statusCode==200) {return [self packageProfile:dataStr];}
	
	return nil;
}

-(void)dealloc {
	[_headerFields release];
	[_serviceName release];
	[_apiKey release];
	[_identityToken release];
	[_identitySecret release];
	[super dealloc];
}

@end

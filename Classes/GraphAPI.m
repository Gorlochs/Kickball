#import "GraphAPI.h"
#import "JSON.h"
#import "FBXMLHandler.h"
#import "TouchXML.h"

NSString* const kGraphAPIServer = @"https://graph.facebook.com/";
NSString* const kRestAPIServer = @"https://api.facebook.com/method/";
// Graph API Argument Keys
NSString* const kArgumentKeyAccessToken = @"access_token";
NSString* const kArgumentKeyMethod = @"method";

// other dictionary keys
NSString* const kKeySearchQuery = @"q";
NSString* const kKeySearchObjectType = @"type";

// other things...
NSString* const kRequestVerbGet = @"GET";
NSString* const kRequestVerbPost = @"POST";
NSString* const kRequestVerbDelete = @"DELETE";

NSString* const kPostStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

#pragma mark Public Constants

// Graph API Argument Keys
NSString* const kKeyArgumentMetadata = @"metadata";
NSString* const kKeyArgumentMessage = @"message";

// search method objectType parameter values
NSString* const kSearchPosts = @"post";
NSString* const kSearchUsers = @"user";
NSString* const kSearchPages = @"page";
NSString* const kSearchEvents = @"event";
NSString* const kSearchGroups = @"group";

// connection types
NSString* const kConnectionFriends = @"friends";
NSString* const kConnectionNews = @"home";
NSString* const kConnectionWall = @"feed";
NSString* const kConnectionFeed = @"feed";
NSString* const kConnectionLikes = @"likes";
NSString* const kConnectionMovies = @"movies";
NSString* const kConnectionBooks = @"books";
NSString* const kConnectionNotes = @"notes";
NSString* const kConnectionPhotos = @"photos";
NSString* const kConnectionVideos = @"videos";
NSString* const kConnectionEvents = @"events";
NSString* const kConnectionGroups = @"groups";

// more connection types, these ones are used for publishing to facebook (among other things)
// http://developers.facebook.com/docs/api#publishing

NSString* const kConnectionComments = @"comments";
NSString* const kConnectionLinks = @"links";
NSString* const kConnectionAttending = @"attending";
NSString* const kConnectionMaybe = @"maybe";
NSString* const kConnectionDeclined = @"declined";
NSString* const kConnectionAlbums = @"albums";

@interface GraphAPI (_PrivateMethods)

-(NSData*)api:(NSString*)obj_id args:(NSMutableDictionary*)request_args;
-(NSData*)api:(NSString*)obj_id args:(NSMutableDictionary*)request_args verb:(NSString*)verb;
-(NSData*)makeSynchronousRequest:(NSString*)path args:(NSMutableDictionary*)request_args verb:(NSString*)verb;
-(NSData*)makeAsynchronousRequest:(NSString*)path args:(NSMutableDictionary*)request_args verb:(NSString*)verb;

-(NSData*)makeSynchronousRest:(NSString*)path args:(NSMutableDictionary*)request_args verb:(NSString*)verb;
-(NSData*)makeSynchronousRequest:(NSString*)fullpath;

-(NSString*)encodeParams:(NSDictionary*)request_args;
-(NSData*)generatePostBody:(NSDictionary*)request_args;
-(NSArray*)graphObjectArrayFromJSON:(NSString*)jsonString;

@end

@implementation GraphAPI

@synthesize _accessToken;
@synthesize _connections;
@synthesize _asyncronousDelegate;
@synthesize _responseData;
@synthesize _isSynchronous;
@synthesize _pagingNext;

#pragma mark Initialization

-(id)initWithAccessToken:(NSString*)access_token
{
	if ( self = [super init] )
	{
		self._accessToken = access_token;
		self._connections = nil;
		self._asyncronousDelegate = nil;
		self._responseData = nil;
		self._isSynchronous = YES;
	}
	return self;	
}

-(void)setSynchronousMode:(BOOL)isSynchronous
{
	if ( self._isSynchronous != isSynchronous )
	{
		// something else will probably happen here too
		self._isSynchronous = isSynchronous;
	}
}

-(void)dealloc
{
	[_pagingNext release];
	[_accessToken release];
	[_connections release];
	[_asyncronousDelegate release];
	[_responseData release];
	[super dealloc];	
}

#pragma mark Public API

-(GraphObject*)getObject:(NSString*)obj_id;
{
	return [self getObject:obj_id withArgs:nil];
}

-(GraphObject*)getObject:(NSString*)obj_id withArgs:(NSDictionary*)request_args
{
	NSString* path = obj_id;
	NSMutableDictionary* mutableArgs = [NSMutableDictionary dictionaryWithDictionary:request_args];
	
	NSData* response = [self api:path args:mutableArgs];
	NSString* r_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	GraphObject* r_obj = [[[GraphObject alloc] initWithString:r_string] autorelease];
	[r_string release];
	return r_obj;
}

-(UIImage*)getProfilePhotoForObject:(NSString*)obj_id withArgs:(NSDictionary*)request_args
{
	NSMutableDictionary* mutableArgs = [NSMutableDictionary dictionaryWithDictionary:request_args];
	NSString* path = [NSString stringWithFormat:@"%@/picture", obj_id];
	
	NSData* response = [self api:path args:mutableArgs];
	UIImage* r_image = [[[UIImage alloc] initWithData:response] autorelease];
	return r_image;	
}

-(UIImage*)getProfilePhotoForObject:(NSString*)obj_id
{
	return [self getProfilePhotoForObject:obj_id withArgs:nil];
}

-(UIImage*)getLargeProfilePhotoForObject:(NSString*)obj_id
{
	NSDictionary* args = [NSDictionary dictionaryWithObject:@"large" forKey:@"type"];
	return [self getProfilePhotoForObject:obj_id withArgs:args];
}

-(NSArray*)getConnections:(NSString*)connection_name forObject:(NSString*)obj_id
{
	NSString* path = [NSString stringWithFormat:@"%@/%@", obj_id, connection_name];

	NSData* response = [self api:path args:nil];
	NSString* r_string =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSArray* connections = [self graphObjectArrayFromJSON:r_string];
	[r_string release];
	return connections;
}

-(NSArray*)getConnectionTypesForObject:(NSString*)obj_id
{
	NSMutableDictionary* args = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", kKeyArgumentMetadata, nil];
	
	GraphObject* responseObj = [self getObject:obj_id withArgs:args];
	
	NSArray* connections = nil;
	
	@try
	{
		if ( nil != responseObj && nil != responseObj._properties )
			connections = [[[responseObj._properties objectForKey:kKeyArgumentMetadata] objectForKey:@"connections"] allKeys];
	}
	@catch (id exception) 
	{
	}
	
	return connections;
}

-(NSArray*)searchTerms:(NSString*)search_terms objectType:(NSString*)objType
{
	NSMutableDictionary* args = [NSMutableDictionary dictionaryWithObjectsAndKeys:search_terms, kKeySearchQuery, objType, kKeySearchObjectType, nil];

	NSString* path = @"search";
	NSData* response = [self api:path args:args];
	NSString* r_string =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSArray* connections = [self graphObjectArrayFromJSON:r_string];
	[r_string release];
	return connections;
}

// This doesn't appear to be working right now
-(NSArray*)searchNewsFeedForUser:(NSString*)user_id searchTerms:(NSString*)search_terms
{
	NSMutableDictionary* args = [NSMutableDictionary dictionaryWithObjectsAndKeys:search_terms, kKeySearchQuery, nil];
	
	NSString* path = [NSString stringWithFormat:@"%@/home", user_id];
	NSData* response = [self api:path args:args];
	NSString* r_string =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	NSArray* connections = [self graphObjectArrayFromJSON:r_string];
	[r_string release];
	return connections;
}

-(NSArray*)newsFeed:(NSString*)user_id
{	
	NSString* path = [NSString stringWithFormat:@"%@/home", user_id];
	NSData* response = [self api:path args:nil];
	NSString* r_string =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	DLog("facebook newsFeed response: %@", r_string);
	NSArray* connections = [self graphObjectArrayFromJSON:r_string];
	[r_string release];
	return connections;
}
-(NSArray*)nextPage:(NSString*)pageURL
{	
	NSData* response = [self makeSynchronousRequest:pageURL];
	NSString* r_string =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	NSArray* connections = [self graphObjectArrayFromJSON:r_string];
	[r_string release];
	return connections;
}

-(NSDictionary*)newMeFeed{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"stream.get";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	SBJSON *parser = [SBJSON new];
	id dict = [parser objectWithString:r_string error:NULL];
	[r_string release];
	[parser release];
	if ([dict isKindOfClass:[NSDictionary class]]) {
		DLog(@"woohoo parsed a dictionary");
		return dict;
	}else {
		DLog(@"parsed and got an array.  bummer.");
		return nil;
	}
}
-(NSDictionary*)newMeFeed:(NSNumber*)timeMarker{
	
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"stream.get";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:[timeMarker stringValue],@"end_time",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	SBJSON *parser = [SBJSON new];
	id dict = [parser objectWithString:r_string error:NULL];
	[parser release];
	[r_string release];
	if ([dict isKindOfClass:[NSDictionary class]]) {
		DLog(@"woohoo parsed a dictionary");
		return dict;
	}else {
		DLog(@"parsed and got an array.  bummer.");
		return nil;
	}
}

-(NSArray*)commentFeedForPost:(NSString*)post_id{
	NSArray* ids = [post_id componentsSeparatedByString:@"_"];
	NSData* responseData = nil;
	NSString* r_string = nil;
	//NSString* method = @"comments.get";
	NSString* method = @"stream.getComments";
	NSMutableDictionary *args = nil;
	if ([ids count]!=2) {
		//there was a problem with the incoming post_id
		return nil;
	}
	//args= [NSMutableDictionary dictionaryWithObjectsAndKeys:[ids objectAtIndex:1],@"object_id",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:post_id,@"post_id",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	//[responseData release];
	SBJSON *parser = [SBJSON new];
	id arr = [parser objectWithString:r_string error:NULL];
	[parser release];
	[r_string release];
	if ([arr isKindOfClass:[NSArray class]]) {
		DLog(@"woohoo parsed an array");
		return arr;
	}else {
		DLog(@"parsed and got a dictionary.  bummer.");
		return nil;
	}
}

-(NSDictionary*)eventFeed:(NSString*)event_id{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"stream.get";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:event_id,@"source_ids",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	//[responseData release];
	SBJSON *parser = [SBJSON new];
	id arr = [parser objectWithString:r_string error:NULL];
	[parser release];
	[r_string release];
	if ([arr isKindOfClass:[NSDictionary class]]) {
		DLog(@"woohoo parsed an dictionary");
		return arr;
	}else {
		DLog(@"parsed and got an array.  bummer.");
		return nil;
	}
}

-(NSArray*)getProfileObjects:(NSArray*)profileIds{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"users.getInfo";
	NSString* fields = @"name,pic_square";
	NSString* profiles = [profileIds componentsJoinedByString:@","];
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:profiles,@"uids",fields,@"fields",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	SBJSON *parser = [SBJSON new];
	id arr = [parser objectWithString:r_string error:NULL];
	[parser release];
	[r_string release];
	if ([arr isKindOfClass:[NSArray class]]) {
		DLog(@"woohoo parsed an array");
		return arr;
	}else {
		DLog(@"parsed and got a dictionary.  bummer.");
		return nil;
	}
}

-(NSArray*)getPhotosForAlbum:(NSString*)aid{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"photos.get";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:aid,@"aid",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	SBJSON *parser = [SBJSON new];
	id arr = [parser objectWithString:r_string error:NULL];
	[parser release];
	[r_string release];
	if ([arr isKindOfClass:[NSArray class]]) {
		DLog(@"woohoo parsed an array");
		return arr;
	}else {
		DLog(@"parsed and got a dictionary.  bummer.");
		return nil;
	}
}

-(NSArray*)eventsFeed:(NSString*)user_id
{	
	/*
	NSString* path = [NSString stringWithFormat:@"%@/events", user_id];
	NSData* response = [self api:path args:nil];
	NSString* r_string =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	GraphObject* baseEventResult = [self graphObjectArrayFromJSON:r_string];
	[r_string release];
	return baseEventResult;
	 */
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"events.get";
	NSMutableDictionary *args = nil;
	
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"unsure",@"rsvp_status",@"XML",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	FBXMLHandler* unsure_handler = [[[FBXMLHandler alloc] init] autorelease];
	NSXMLParser* unsure_parser = [[[NSXMLParser alloc] initWithData:responseData] autorelease];
	unsure_parser.delegate = unsure_handler;
	[unsure_parser parse];
	for(NSMutableDictionary *event in unsure_handler.rootObject){
		if ([event isKindOfClass:[NSMutableDictionary class]]) {
			[event setObject:@"unsure" forKey:@"rsvp_status"];
		}
	}
	NSArray *returnArray = [NSArray arrayWithArray:unsure_handler.rootObject];
	
	[r_string release];
	
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"attending",@"rsvp_status",@"XML",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	FBXMLHandler* attending_handler = [[[FBXMLHandler alloc] init] autorelease];
	NSXMLParser* attending_parser = [[[NSXMLParser alloc] initWithData:responseData] autorelease];
	attending_parser.delegate = attending_handler;
	[attending_parser parse];
	//NSArray *attendingResults = attending_handler.rootObject;
	for(NSMutableDictionary *event in attending_handler.rootObject){
		if ([event isKindOfClass:[NSMutableDictionary class]]) {
			[event setObject:@"attending" forKey:@"rsvp_status"];
		}
	}
	
	returnArray = [returnArray arrayByAddingObjectsFromArray:attending_handler.rootObject];
	[r_string release];

	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"declined",@"rsvp_status",@"XML",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	FBXMLHandler* declined_handler = [[[FBXMLHandler alloc] init] autorelease];
	NSXMLParser* declined_parser = [[[NSXMLParser alloc] initWithData:responseData] autorelease];
	declined_parser.delegate = declined_handler;
	[declined_parser parse];
	//NSArray *declinedResults = declined_handler.rootObject;
	for(NSMutableDictionary *event in declined_handler.rootObject){
		if ([event isKindOfClass:[NSMutableDictionary class]]) {
			[event setObject:@"declined" forKey:@"rsvp_status"];
		}
	}
	returnArray = [returnArray arrayByAddingObjectsFromArray:declined_handler.rootObject];
	[r_string release];

	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:@"not_replied",@"rsvp_status",@"XML",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	FBXMLHandler* not_replied_handler = [[[FBXMLHandler alloc] init] autorelease];
	NSXMLParser* not_replied_parser = [[[NSXMLParser alloc] initWithData:responseData] autorelease];
	not_replied_parser.delegate = not_replied_handler;
	[not_replied_parser parse];
	//NSArray *not_repliedResults = not_replied_handler.rootObject;
	for(NSMutableDictionary *event in not_replied_handler.rootObject){
		if ([event isKindOfClass:[NSMutableDictionary class]]) {
			[event setObject:@"not_replied" forKey:@"rsvp_status"];
		}
	}
	returnArray = [returnArray arrayByAddingObjectsFromArray:not_replied_handler.rootObject];
	[r_string release];
	
	
	//GraphObject *some = nil;
	return returnArray;
}

-(void)postToWall:(NSString*)message withImage:(UIImage*)photo{
	NSData* responseData = nil;
	//NSString* r_string = nil;
	NSString* method = @"photos.upload";
	NSMutableDictionary *args = nil;
	
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:self._accessToken,kArgumentKeyAccessToken,photo,@"photo",message,@"caption",nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbPost];
	//r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
}

-(void)simpleStatusPost:(NSString*)message{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"users.setStatus";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:message,@"status",@"true",@"status_includes_verb",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[r_string release];
}

-(GraphObject*)putToObject:(NSString*)parent_obj_id connectionType:(NSString*)connection args:(NSDictionary*)request_args
{
	NSMutableDictionary* mutableArgs = [NSMutableDictionary dictionaryWithDictionary:request_args];
	
	NSString* path = [NSString stringWithFormat:@"%@/%@", parent_obj_id, connection];
	NSData* responseData	= [self api:path args:mutableArgs verb:kRequestVerbPost];
	NSString* r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	GraphObject* r_obj = [[[GraphObject alloc] initWithString:r_string] autorelease];
	[r_string release];
	return r_obj;
}

//# attachment adds a structured attachment to the status message being
//# posted to the Wall. It should be a dictionary of the form:
//# 
//#     {"name": "Link name"
//#      "link": "http://www.example.com/",
//#      "caption": "{*actor*} posted a new review",
//#      "description": "This is a longer description of the attachment",
//#      "picture": "http://www.example.com/thumbnail.jpg"}

-(GraphObject*)putWallPost:(NSString*)profile_id message:(NSString*)message attachment:(NSDictionary*)attachment_args
{
	NSMutableDictionary* mutableArgs = nil;

	if ( nil != attachment_args )
	{
		mutableArgs = [NSMutableDictionary dictionaryWithDictionary:attachment_args];
	}
	else
	{
		mutableArgs = [NSMutableDictionary dictionaryWithCapacity:2];
	}
	[mutableArgs setObject:message forKey:kKeyArgumentMessage];

	return [self putToObject:profile_id connectionType:kConnectionWall args:mutableArgs];
}

-(void)likeObject:(NSString*)obj_id
{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"stream.addLike";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:obj_id,@"post_id",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[r_string release];
	
	//return [self putToObject:obj_id connectionType:kConnectionLikes args:nil];
}
-(void)unlikeObject:(NSString*)obj_id
{
	NSData* responseData = nil;
	NSString* r_string = nil;
	NSString* method = @"stream.removeLike";
	NSMutableDictionary *args = nil;
	args= [NSMutableDictionary dictionaryWithObjectsAndKeys:obj_id,@"post_id",@"json",@"format",self._accessToken,kArgumentKeyAccessToken,nil];
	responseData = [self makeSynchronousRest:method args:args verb:kRequestVerbGet];
	r_string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[r_string release];
	//return [self putToObject:obj_id connectionType:kConnectionLikes args:nil];
}

-(GraphObject*)attendObject:(NSString*)obj_id
{
	return [self putToObject:obj_id connectionType:kConnectionAttending args:nil];
}
-(GraphObject*)declineObject:(NSString*)obj_id
{
	return [self putToObject:obj_id connectionType:kConnectionDeclined args:nil];
}

-(GraphObject*)putCommentToObject:(NSString*)obj_id message:(NSString*)message
{
	NSMutableDictionary* args = [NSMutableDictionary dictionaryWithObjectsAndKeys:message, kKeyArgumentMessage, nil];
	return [self putToObject:obj_id connectionType:kConnectionComments args:args];
}


-(bool)deleteObject:(NSString*)obj_id
{
	NSString* path = obj_id;	
	NSData* responseData = [self api:path args:nil verb:kRequestVerbDelete];
	NSString* r_string = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	
	// for this api, and I think only this api, facebook does not return proper JSON, just true/false
	bool successResponse = [r_string boolValue];
	
	return successResponse;
}

#pragma mark Private Implementation Methods

-(NSData*)api:(NSString*)obj_id args:(NSMutableDictionary*)request_args
{
	return [self api:obj_id args:request_args verb:kRequestVerbGet];
}

-(NSData*)api:(NSString*)obj_id args:(NSMutableDictionary*)request_args verb:(NSString*)verb
{
	if ( nil != self._accessToken )
	{
		if ( nil == request_args )
		{
			request_args = [NSMutableDictionary dictionaryWithCapacity:1];
		}
		[request_args setObject:self._accessToken forKey:kArgumentKeyAccessToken];
	}
								 
	NSData* response = nil;

	// will probably want to generally use async calls, but building this with sync first is easiest
	if (self._isSynchronous)
		response = [self makeSynchronousRequest:obj_id args:request_args verb:verb];
	else
		response = [self makeAsynchronousRequest:obj_id args:request_args verb:verb];
	
	return response;
}

-(NSData*)makeAsynchronousRequest:(NSString*)path args:(NSMutableDictionary*)request_args verb:(NSString*)verb
{
	// if the verb isn't get or post, send it as a post argument
	if ( kRequestVerbGet != verb && kRequestVerbPost != verb )
	{
		[request_args setObject:verb forKey:kArgumentKeyMethod];
		verb = kRequestVerbPost;
	}
	
	//	NSString* responseString = nil;
	self._responseData = nil;
	NSString* urlString = nil;
	NSMutableURLRequest* r_url;
	
	if ( [verb isEqualToString:kRequestVerbGet] )
	{
		NSString* argString = [self encodeParams:request_args];
		
		urlString = [NSString stringWithFormat:@"%@%@?%@", kGraphAPIServer, path, argString];
		
		r_url = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
														 cachePolicy:NSURLRequestUseProtocolCachePolicy
												 timeoutInterval:60.0];
	}
	else
	{
		urlString = [NSString stringWithFormat:@"%@%@", kGraphAPIServer, path];
		
		r_url = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
																		cachePolicy:NSURLRequestUseProtocolCachePolicy
																timeoutInterval:60.0];
		
		NSData* postBody = [self generatePostBody:request_args];
		NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kPostStringBoundary];
		
		[r_url setHTTPMethod:kRequestVerbPost];
		[r_url setValue:contentType forHTTPHeaderField:@"Content-Type"];
		[r_url setHTTPBody:postBody];			
	}
	
	//	NSLog( @"fetching url:\n%@", urlString );	
	//	NSLog( @"request headers: %@", [r_url allHTTPHeaderFields] );
	
//	NSURLResponse* response;
	NSError* error = nil;
	
	if ( nil == self._asyncronousDelegate )
		self._asyncronousDelegate = [[GraphDelegate alloc] init];
	
	// async call
	NSURLConnection* newConnection = [NSURLConnection connectionWithRequest:r_url delegate:self._asyncronousDelegate];// [[NSURLConnection alloc] initWithRequest:r_url delegate:self._asyncronousDelegate];
	
	if ( nil != newConnection )
	{
		[self._connections addObject:newConnection];
	}
	else
	{
		NSLog(@"Connection failed!\n URL = %@\n Error - %@ %@",
					urlString,
					[error localizedDescription],						
					[[error userInfo] objectForKey:@"NSUnderlyingError"]);
	}
	
	return nil;
}

-(NSData*)makeSynchronousRequest:(NSString*)path args:(NSMutableDictionary*)request_args verb:(NSString*)verb
{
	// if the verb isn't get or post, send it as a post argument
	if ( kRequestVerbGet != verb && kRequestVerbPost != verb )
	{
		[request_args setObject:verb forKey:kArgumentKeyMethod];
		verb = kRequestVerbPost;
	}

//	NSString* responseString = nil;
	self._responseData = nil;
	NSString* urlString;
	NSMutableURLRequest* r_url;
	
	if ( [verb isEqualToString:kRequestVerbGet] )
	{
		NSString* argString = [self encodeParams:request_args];
		
		urlString = [NSString stringWithFormat:@"%@%@?%@", kGraphAPIServer, path, argString];
	
		r_url = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
														 cachePolicy:NSURLRequestUseProtocolCachePolicy
												 timeoutInterval:60.0];
	}
	else
	{
		urlString = [NSString stringWithFormat:@"%@%@", kGraphAPIServer, path];
		
		r_url = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
														 cachePolicy:NSURLRequestUseProtocolCachePolicy
												 timeoutInterval:60.0];
		
		NSData* postBody = [self generatePostBody:request_args];
		NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kPostStringBoundary];

		[r_url setHTTPMethod:kRequestVerbPost];
		[r_url setValue:contentType forHTTPHeaderField:@"Content-Type"];
		[r_url setHTTPBody:postBody];			
	}
	
	//	NSLog( @"fetching url:\n%@", urlString );	
	//	NSLog( @"request headers: %@", [r_url allHTTPHeaderFields] );
	
	NSURLResponse* response;
	NSError* error;
	
	// synchronous call
	self._responseData = [NSURLConnection sendSynchronousRequest:r_url returningResponse:&response error:&error];

	// async
	// self._connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		
//	if ( [verb isEqualToString:kRequestVerbPost] )
//	{
//		NSLog( @"Post response:" );
//		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//
//		NSLog( @"status: %d, %@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] );	
//		NSLog( @"response headers: %@", [httpResponse allHeaderFields] );
//		NSLog( @"response: %@", self._responseData );
//	}
	
	
	if ( nil == self._responseData )
	{
		NSLog(@"Connection failed!\n URL = %@\n Error - %@ %@",
					urlString,
					[error localizedDescription],						
					[[error userInfo] objectForKey:@"NSUnderlyingError"]);
	}

	return self._responseData;
}

-(NSData*)makeSynchronousRequest:(NSString*)fullpath{
	NSMutableURLRequest  *r_url = [NSURLRequest requestWithURL:[NSURL URLWithString:fullpath]
							 cachePolicy:NSURLRequestUseProtocolCachePolicy
						 timeoutInterval:60.0];
	NSURLResponse* response;
	NSError* error;
	
	// synchronous call
	self._responseData = [NSURLConnection sendSynchronousRequest:r_url returningResponse:&response error:&error];
	if ( nil == self._responseData )
	{
		NSLog(@"Connection failed!\n URL = %@\n Error - %@ %@",
			  fullpath,
			  [error localizedDescription],						
			  [[error userInfo] objectForKey:@"NSUnderlyingError"]);
	}
	
	return self._responseData;
}

-(NSData*)makeSynchronousRest:(NSString*)path args:(NSMutableDictionary*)request_args verb:(NSString*)verb
{
	// if the verb isn't get or post, send it as a post argument
	if ( kRequestVerbGet != verb && kRequestVerbPost != verb )
	{
		[request_args setObject:verb forKey:kArgumentKeyMethod];
		verb = kRequestVerbPost;
	}
	
	//	NSString* responseString = nil;
	self._responseData = nil;
	NSString* urlString;
	NSMutableURLRequest* r_url;
	
	if ( [verb isEqualToString:kRequestVerbGet] )
	{
		NSString* argString = [self encodeParams:request_args];
		
		urlString = [NSString stringWithFormat:@"%@%@?%@", kRestAPIServer, path, argString];
		
		r_url = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
								 cachePolicy:NSURLRequestUseProtocolCachePolicy
							 timeoutInterval:60.0];
	}
	else
	{
		urlString = [NSString stringWithFormat:@"%@%@", kRestAPIServer, path];
		
		r_url = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
										cachePolicy:NSURLRequestUseProtocolCachePolicy
									timeoutInterval:60.0];
		
		NSData* postBody = [self generatePostBody:request_args];
		NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kPostStringBoundary];
		
		[r_url setHTTPMethod:kRequestVerbPost];
		[r_url setValue:contentType forHTTPHeaderField:@"Content-Type"];
		[r_url setHTTPBody:postBody];			
	}
	
	//	NSLog( @"fetching url:\n%@", urlString );	
	//	NSLog( @"request headers: %@", [r_url allHTTPHeaderFields] );
	
	NSURLResponse* response;
	NSError* error;
	
	// synchronous call
	self._responseData = [NSURLConnection sendSynchronousRequest:r_url returningResponse:&response error:&error];
	
	// async
	// self._connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	//	if ( [verb isEqualToString:kRequestVerbPost] )
	//	{
	//		NSLog( @"Post response:" );
	//		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	//
	//		NSLog( @"status: %d, %@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] );	
	//		NSLog( @"response headers: %@", [httpResponse allHeaderFields] );
	//		NSLog( @"response: %@", self._responseData );
	//	}
	
	
	if ( nil == self._responseData )
	{
		NSLog(@"Connection failed!\n URL = %@\n Error - %@ %@",
			  urlString,
			  [error localizedDescription],						
			  [[error userInfo] objectForKey:@"NSUnderlyingError"]);
	}
	
	return self._responseData;
}

-(NSString*)encodeParams:(NSDictionary*)request_args
{
	NSMutableString* argString = [NSMutableString stringWithString:@""];
	NSUInteger arg_count = [request_args count];
	uint i = 0;
	
	for ( NSString* i_key in request_args ) 
	{
		i++;
		[argString appendFormat:@"%@=%@", i_key, [self _encodeString:[request_args objectForKey:i_key]]];
		if ( i < arg_count )
			[argString appendString:@"&"];
	}
	return argString; //[argString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}
- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
																		   (CFStringRef)string, 
																		   NULL, 
																		   (CFStringRef)@";/?:@&=$+{}<>,.",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}


-(NSData*)generatePostBody:(NSDictionary*)request_args
{
  NSMutableData *body = [NSMutableData data];
  NSString *beginLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kPostStringBoundary];
	
  [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kPostStringBoundary]
										dataUsingEncoding:NSUTF8StringEncoding]];
  
  for (id key in [request_args keyEnumerator])
	{
    NSString* value = [request_args valueForKey:key];
    if (![value isKindOfClass:[UIImage class]]) 
		{
      [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];        
      [body appendData:[[NSString
												 stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
												dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }
	
  for (id key in [request_args keyEnumerator]) 
	{
    if ([[request_args objectForKey:key] isKindOfClass:[UIImage class]]) 
		{
      UIImage* image = [request_args objectForKey:key];
      CGFloat quality =  0.75;
      NSData* data = UIImageJPEGRepresentation(image, quality);
      
      [body appendData:[beginLine dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString stringWithFormat:
												 @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n",
												 key]
												dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString
												 stringWithFormat:@"Content-Length: %d\r\n", data.length]
												dataUsingEncoding:NSUTF8StringEncoding]];  
      [body appendData:[[NSString
												 stringWithString:@"Content-Type: image/jpeg\r\n\r\n"]
												dataUsingEncoding:NSUTF8StringEncoding]];  
      [body appendData:data];
    }
  }
  	
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kPostStringBoundary]
										dataUsingEncoding:NSUTF8StringEncoding]];
	
//  NSLog(@"post body sending\n%s", [body bytes]);
  return body;
}

-(NSArray*)graphObjectArrayFromJSON:(NSString*)jsonString
{
	GraphObject* r_obj = [[GraphObject alloc] initWithString:jsonString];
	NSMutableArray* connections = nil;
	
	@try
	{
		if ( nil != r_obj && nil != r_obj._properties )
		{
			// this should be an array of dictionaries, we turn it into an array of GraphObjects
			NSArray* jsonConnections = [r_obj._properties objectForKey:@"data"];
			connections = [NSMutableArray arrayWithCapacity:[jsonConnections count]];
			for ( NSDictionary* i_like in jsonConnections )
			{
				GraphObject* i_obj = [[GraphObject alloc] initWithDict:i_like];
				[connections addObject:i_obj];
				[i_obj release];				
			}
			NSDictionary *paging = [r_obj._properties objectForKey:@"paging"];
			if (paging!=nil) {
				_pagingNext = [[NSString alloc] initWithString:[paging objectForKey:@"next"]];
			}
			
		}
	}
	@catch (id exception) 
	{
	}
	
	[r_obj release];
	return connections;	
}

@end

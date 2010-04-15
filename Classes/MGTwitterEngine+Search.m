//
//  MGTwitterEngine+Search.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 10/9/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "MGTwitterEngine+Search.h"

@implementation MGTwitterEngine (Search)

- (NSString *)getSearchSavedResult:(int)pageNum count:(int)count
{
    NSString *path = [NSString stringWithFormat:@"saved_searches.%@", API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	if (pageNum > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", pageNum] forKey:@"page"];
    }
    if (count > 0) {
        [params setObject:[NSString stringWithFormat:@"%d", count] forKey:@"rpp"];
    }
	
    return [self _sendRequestWithMethod:nil path:path queryParameters:params body:nil 
                            requestType:MGTwitterSearchManage
                           responseType:MGTwitterSearchResults];
}
/*
- (NSString *)getSearchSavedResultById:(int)queryID
{
    NSString *path = [NSString stringWithFormat:@"saved_searches/show/%i.%@", queryID, API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	if (queryID > 0) {
		[params setObject:[NSString stringWithFormat:@"%d", queryID] forKey:@"id"];
	}
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:params body:nil
                            requestType:MGTwitterSearchManage 
                           responseType:MGTwitterSearchResults];    
}
*/
- (NSString *)getSearchSavedResultById:(NSString*)queryID
{
    NSString *path = [NSString stringWithFormat:@"saved_searches/show/%@.%@", queryID, API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	if (queryID > 0) {
		[params setObject:queryID forKey:@"id"];
	}
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:params body:nil
                            requestType:MGTwitterSearchManage 
                           responseType:MGTwitterSearchResults];    
}

- (NSString *)searchSaveQuery:(NSString *)query
{
    NSString *path = [NSString stringWithFormat:@"saved_searches/create.%@", API_FORMAT];
	NSString *theBody = [NSString stringWithFormat:@"query=%@", query];
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:theBody 
                            requestType:MGTwitterSearchSave 
                           responseType:MGTwitterSearchResults];
}
/*
- (NSString *)searchDestroyQuery:(int)queryID
{
    NSString *path = [NSString stringWithFormat:@"saved_searches/destroy/%i.%@", queryID, API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	if (queryID > 0) {
		[params setObject:[NSString stringWithFormat:@"%d", queryID] forKey:@"id"];
	}
    
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:params body:nil
                            requestType:MGTwitterSearchDestroy 
                           responseType:MGTwitterSearchResults];
}
*/
- (NSString *)searchDestroyQuery:(NSString*)queryID
{
    NSString *path = [NSString stringWithFormat:@"saved_searches/destroy/%@.%@", queryID, API_FORMAT];
    return [self _sendRequestWithMethod:HTTP_POST_METHOD path:path queryParameters:nil body:nil
                            requestType:MGTwitterSearchDestroy 
                           responseType:MGTwitterSearchResults];
}

@end

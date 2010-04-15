//
//  SearchProvider.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 10/16/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "SearchProvider.h"
#import "MGTwitterEngine.h"
#import "MGTwitterEngine+Search.h"
#import "MGTwitterEngineFactory.h"

@interface SearchProvider(Private)

- (void)notifyAboutEndOfSearch:(NSArray*)result forQuery:(NSString*)query;
- (void)setNotificationValue:(SPNotificationValue)value forIdentifier:(NSString *)identifier;
- (void)setNotificationValue:(SPNotificationValue)value forIdentifier:(NSString *)identifier forQuery:(NSString *)query;
- (void)removeNotification:(NSString *)identifier;
- (SPNotificationValue)notificationForIdentifier:(NSString *)identifier;
- (NSString *)queryForIdentifier:(NSString *)identifier;
- (BOOL)validateQuery:(NSString *)query;
- (void)updateQueries:(NSArray *)data;

@end

@implementation SearchProvider

// Instance of shared search provider
static SearchProvider *sharedProvider = nil;

@synthesize twitter = _twitter;
@synthesize delegate = _delegate;

+ (SearchProvider *)providerWithDelegate:(id)delegate
{
    SearchProvider *provider = [[SearchProvider alloc] initWithDelegate:delegate];
    return [provider autorelease];
}

+ (SearchProvider *)sharedProviderUsingDelegate:(id)delegate
{
    if (sharedProvider == nil)
        sharedProvider = [[SearchProvider alloc] initWithDelegate:delegate];
    else
        sharedProvider.delegate = delegate;
    return sharedProvider;
}

+ (SearchProvider *)sharedProviderRelease
{
    if (sharedProvider)
    {
        [sharedProvider setDelegate:nil];
        [sharedProvider release];
        sharedProvider = nil;
    }
    return nil;
}

- (id)init
{
    NSAssert(NO, @"Use initWithTwitterEngine method for init object");
    return nil;
}

- (id)initWithDelegate:(id)delegate
{
    if ((self = [super init]))
    {
        _queries = [[NSMutableDictionary alloc] init];
        _twitterConnection = [[NSMutableDictionary alloc] init];
        //_twitter = [[MGTwitterEngine alloc] initWithDelegate:self];
        _twitter = [[MGTwitterEngineFactory createTwitterEngineForCurrentUser:self] retain];
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self closeSearch];
    self.delegate = nil;
    [_twitter release];
    [_twitterConnection release];
    [_queries release];
    [super dealloc];
}

// Update object state
- (void)update
{
    NSString *identifier = [self.twitter getSearchSavedResult:0 count:0];
    [self setNotificationValue:SPUpdateState forIdentifier:identifier];
}

// Return YES if query string present in dictionary
- (BOOL)hasQuery:(NSString *)query
{
    return ([[_queries allKeys] indexOfObject:query] != NSNotFound);
}

// Return YES if query with query id present in dictionary
/*
- (BOOL)hasQueryById:(int)queryId
{
    NSNumber *value = [NSNumber numberWithInt:queryId];
    return ([[_queries allValues] indexOfObjectIdenticalTo:value] != NSNotFound);
}
*/
- (BOOL)hasQueryById:(NSString*)queryId
{
    return ([[_queries allValues] indexOfObjectIdenticalTo:queryId] != NSNotFound);
}

// Save query string in tweeter
/*
- (void)saveQuery:(NSString *)query forId:(int)queryId
{
   if (![self hasQuery:query])
    {
        NSString *identifier = [_twitter searchSaveQuery:query];
        [self setNotificationValue:SPSearchDidSaved forIdentifier:identifier];
    }
}
*/
- (void)saveQuery:(NSString *)query forId:(NSString*)queryId
{
    if (![self hasQuery:query])
    {
        NSString *identifier = [_twitter searchSaveQuery:query];
        [self setNotificationValue:SPSearchDidSaved forIdentifier:identifier];
    }
}

// Remove saved search query
- (void)removeQuery:(NSString *)query
{
    YFLog(@"REMOVEW_QUERY: %@", query);
    NSString *queryId = [self queryId:query];
    
    if (queryId != nil && [queryId longLongValue] > 0)
    {
        [_twitter searchDestroyQuery:queryId];
        [_queries removeObjectForKey:query];
        [self updateQueries:nil];
    }
}

// Remove saved search query with query id
/*
- (void)removeQueryById:(int)queryId
{
    if (queryId > 0)
    {
        NSString *query = [self queryById:queryId];

        if (query)
        {
            [_twitter searchDestroyQuery:queryId];
            [_queries removeObjectForKey:query];
            [self updateQueries:nil];
        }
    }
}
*/
- (void)removeQueryById:(NSString*)queryId
{
    YFLog(@"REMOVE_QUERY_BY_ID: %@", queryId);
    if (queryId)
    {
        NSString *query = [self queryById:queryId];
        
        YFLog(@"Query: %@", query);
        if (query)
        {
            [_twitter searchDestroyQuery:queryId];
            [_queries removeObjectForKey:query];
            [self updateQueries:nil];
        }
    }
}

// Return query string by id
/*
- (NSString *)queryById:(int)queryId
{
    NSString *query = nil;
    for (NSString *key in [_queries allKeys])
    {
        if ([[_queries objectForKey:key] intValue] == queryId)
        {
            query = key;
            break;
        }
    }
    return query;
}
*/
- (NSString *)queryById:(NSString*)queryId
{
    NSString *query = nil;
    for (NSString *key in [_queries allKeys])
    {
        NSString *value = [_queries objectForKey:key];
        if (value && [value isEqualToString:queryId])
        {
            query = key;
            break;
        }
    }
    return query;
}

// Return id for query string
/*
- (int)queryId:(NSString *)query
{
    NSNumber *value = [_queries objectForKey:query];
    if (!value)
        return 0;
    return [value unsignedLongValue];
}
 */
- (NSString*)queryId:(NSString *)query
{
    return [_queries objectForKey:query];
}


// Return queries array
- (NSArray *)allQueries
{
    return [_queries allKeys];
}

- (BOOL)isEndOfSearch
{
    if (_connections == nil || [_connections count] == 0)
        return YES;
    return NO;
}

- (void)closeSearch
{
    if ([self isEndOfSearch] == NO) {
        [_connections release];
        [_searchResult release];
        _connections = nil;
        _searchResult = nil;
    }
    [_twitter closeAllConnections];
}

#pragma mark MGTwitterEngineDelegate
- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier
{
    YFLog(@"SEARCH RESULT FOR ID: %@", connectionIdentifier);
    
    SPNotificationValue notification = [self notificationForIdentifier:connectionIdentifier];
    
    //YFLog(@"%@", searchResults);
    if (notification == SPInvalidValue)
        return;
    
    switch (notification) 
    {
        case SPSearchDidSaved:
            [self updateQueries:searchResults];
            break;
        case SPSearchData:
            if (_connections) [_connections release];
            if (_searchResult) [_searchResult release];
            
            _connections = [NSMutableDictionary new];
            _searchResult = [NSMutableArray new];
            
            for (NSDictionary *item in searchResults) {
                id itemId = [item objectForKey:@"id"];
                if (itemId) {
                    NSString *updateConnectionIdent = [_twitter getUpdate:[itemId stringValue]];
                    YFLog(@"UPDATE_CONNECTION_ID: %@, STATUS_ID: %@", updateConnectionIdent, [itemId stringValue]);
                    NSString *queryConnectionIdent = [[connectionIdentifier copy] autorelease];
                    [_connections setObject:queryConnectionIdent forKey:updateConnectionIdent];
                }
            }
            break;
        case SPSavedSearch:
            [self updateQueries:searchResults];
            if (self.delegate && [self.delegate respondsToSelector:@selector(searchSavedSearchReceived:)])
            {
                [self.delegate performSelector:@selector(searchSavedSearchReceived:) withObject:searchResults];
            }
            break;
        case SPUpdateState:
            [self updateQueries:searchResults];
        default:
            break;
    }
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error 
{
    YFLog(@"FAILED_CONNECTION: %@", connectionIdentifier);
    NSString *query = [_connections objectForKey:connectionIdentifier];
    if (query) 
    {
        [_connections removeObjectForKey:connectionIdentifier];
    } 
    else 
    {
        query = [self queryForIdentifier:connectionIdentifier];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchDidEndWithError:)]) 
    {
        [self.delegate performSelector:@selector(searchDidEndWithError:) withObject:query];
    }
}

#pragma mark Unusable MGTwitterEngineDelegate methods
- (void)requestSucceeded:(NSString *)connectionIdentifier 
{
    YFLog(@"REQUEST SUCCEEDED FOR ID: %@", connectionIdentifier);
}

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier {}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier 
{
    YFLog(@"CURRENT CONNECTION ID: %@", connectionIdentifier);
    YFLog(@"ALL CONNECTIONS: %@", _connections);
    NSString *searchIdentifier = [[_connections objectForKey:connectionIdentifier] retain];
    [_connections removeObjectForKey:connectionIdentifier];
    if (statuses && [statuses count] > 0) 
    {
        NSString *query = nil;
        NSDictionary *item = [statuses objectAtIndex:0];
        if (item != nil && [item objectForKey:@"id"]) 
        {
            query = [self queryForIdentifier:searchIdentifier];
            [_searchResult addObject:item];
        }
        if (query)
            [self notifyAboutEndOfSearch:statuses forQuery:query];
    }
    [searchIdentifier release];
}

- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier {}
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {}
- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier {}
- (void)imageReceived:(UIImage *)image forRequest:(NSString *)connectionIdentifier {}
- (void)connectionFinished {}

@end

@implementation SearchProvider(SearchMethods)

- (void)search:(NSString *)query
{
    if ([self validateQuery:query] == YES)
    {
        NSString *identifier = [_twitter getSearchResultsForQuery:query];
        [self setNotificationValue:SPSearchData forIdentifier:identifier forQuery:query];
    }
}

- (void)search:(NSString *)query fromPage:(int)page count:(int)count
{
    if ([self validateQuery:query] == YES)
    {
        NSString *identifier = [_twitter getSearchResultsForQuery:query sinceID:0 startingAtPage:page count:count];
        [self setNotificationValue:SPSearchData forIdentifier:identifier forQuery:query];
    }
}
/*
- (void)searchForQueryId:(int)queryId
{
    NSString *query = [self queryById:queryId];
    
    if ([self validateQuery:query] == YES)
    {
        NSString *identifier = [_twitter getSearchSavedResultById:queryId];
        [self setNotificationValue:SPSearchData forIdentifier:identifier forQuery:query];
    }
}
*/
- (void)searchForQueryId:(NSString*)queryId
{
    NSString *query = [self queryById:queryId];
    
    if ([self validateQuery:query] == YES)
    {
        NSString *identifier = [_twitter getSearchSavedResultById:queryId];
        [self setNotificationValue:SPSearchData forIdentifier:identifier forQuery:query];
    }
}
/*
- (void)searchForQueryId:(int)queryId fromPage:(int)page count:(int)count
{
    [self searchForQueryId:queryId];
}
*/
- (void)searchForQueryId:(NSString*)queryId fromPage:(int)page count:(int)count
{
    [self searchForQueryId:queryId];
}

- (void)savedSearch
{
    NSString *identifier = [_twitter getSearchSavedResult:0 count:0];
    [self setNotificationValue:SPSavedSearch forIdentifier:identifier];
}

@end

@implementation SearchProvider(Private)

- (void)notifyAboutEndOfSearch:(NSArray*)result forQuery:(NSString*)query
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchDidEnd:forQuery:)])
    {
        [self.delegate performSelector:@selector(searchDidEnd:forQuery:) withObject:result withObject:query];
    }
}

- (void)setNotificationValue:(SPNotificationValue)value forIdentifier:(NSString *)identifier
{
    [self setNotificationValue:value forIdentifier:identifier forQuery:nil];
}

- (void)setNotificationValue:(SPNotificationValue)value forIdentifier:(NSString *)identifier forQuery:(NSString *)query
{
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithInt:value], query, nil];
    
    [_twitterConnection setObject:values forKey:identifier];
}

- (void)removeNotification:(NSString *)identifier
{
    [_twitterConnection removeObjectForKey:identifier];
}

- (SPNotificationValue)notificationForIdentifier:(NSString *)identifier
{
    NSArray *value = [_twitterConnection objectForKey:identifier];
    if (value == nil)
        return SPInvalidValue;
    return [[value objectAtIndex:0] intValue];
}

- (NSString *)queryForIdentifier:(NSString *)identifier
{
    @try
    {
        NSArray *value = [_twitterConnection objectForKey:identifier];
        if (value == nil || [value count] < 2)
            return nil;
        return [value objectAtIndex:1];
    }
    @catch (...) {
    }
    return nil;
}

- (BOOL)validateQuery:(NSString *)query
{
    return YES;
}

- (void)updateQueries:(NSArray *)data
{
    @synchronized(self)
    {
        // Update queries
        if (data != nil)
        {
            for (NSDictionary *search in data)
            {
                NSString *query = [NSString stringWithString:[search objectForKey:@"query"]];
                //int queryId = [[search objectForKey:@"id"] intValue];
                NSString *queryId = [[search objectForKey:@"id"] stringValue];
                
                //[_queries setObject:[NSNumber numberWithInt:queryId] forKey:query];
                [_queries setObject:queryId forKey:query];
            }
        }
        // Notificate delegate object about changing
        if (self.delegate && [self.delegate respondsToSelector:@selector(searchProviderDidUpdated)])
        {
            [self.delegate performSelector:@selector(searchProviderDidUpdated)];
        }
    }
}

@end
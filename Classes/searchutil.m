//
//  searchutil.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/23/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#include "searchutil.h"
#include "util.h"

const NSString *SearchDataKey = @"SavedSearchData";

/**
 Return YES if term present at saved search data. Else return NO.
 */
BOOL presentAtSavedSearchTerms(NSString *term)
{
    NSArray *terms = [[NSUserDefaults standardUserDefaults] arrayForKey:(NSString*)SearchDataKey];

    BOOL success = NO;
    if (!isNullable(terms) && [terms count] > 0)
        success = [terms containsObject:term];

    return success;
}

/**
 Save current term to search data. Create search data array if it is nil.
 */
BOOL saveSearchTerm(NSString *term)
{
    if (presentAtSavedSearchTerms(term))
        return YES;
    
    NSArray *savedArray = [[NSUserDefaults standardUserDefaults] arrayForKey:(NSString*)SearchDataKey];
    NSMutableArray *terms = [NSMutableArray arrayWithArray:savedArray];

    BOOL success = NO;
    if (isNullable(terms))
        terms = [[[NSMutableArray alloc] init] autorelease];
    
    if (terms)
    {
        [terms addObject:term];
        [[NSUserDefaults standardUserDefaults] setObject:terms forKey:(NSString*)SearchDataKey];
        success = YES;
    }
    return success;
}

/**
 Remove term from search data.
 */
BOOL removeSearchTerm(NSString *term)
{
    NSArray *savedArray = [[NSUserDefaults standardUserDefaults] arrayForKey:(NSString*)SearchDataKey];
    NSMutableArray *terms = [NSMutableArray arrayWithArray:savedArray];
    
    BOOL success = NO;
    if (!isNullable(terms))
    {
        [terms removeObject:term];
        [[NSUserDefaults standardUserDefaults] setObject:terms forKey:(NSString*)SearchDataKey];
        success = YES;
    }
    
    return success;
}

/**
 Return count of saved data
 */
int getSavedSearchCount()
{
    NSArray *terms = [[NSUserDefaults standardUserDefaults] arrayForKey:(NSString*)SearchDataKey];
    if (isNullable(terms))
        return 0;
    return [terms count];
}

/**
 Return saved search array.
 */
NSArray* getSavedSearchArray()
{
    NSArray *terms = [[NSUserDefaults standardUserDefaults] arrayForKey:(NSString*)SearchDataKey];
    if (isNullable(terms))
        return [NSArray array];
    return terms;
}

//
//  searchutil.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/23/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#ifndef __SearchUtil_h__
#define __SearchUtil_h__

#import <Foundation/Foundation.h>

extern const NSString *SearchDataKey;
/**
    Return YES if term present at saved search data. Else return NO.
 */
BOOL presentAtSavedSearchTerms(NSString *term);

/**
    Save current term to search data. Create search data array if it is nil.
 */
BOOL saveSearchTerm(NSString *term);

/**
    Remove term from search data.
 */
BOOL removeSearchTerm(NSString *term);

/**
    Return count of saved data
 */
int getSavedSearchCount();

/**
    Return saved search array.
 */
NSArray* getSavedSearchArray();

#endif //__SearchUtil_h__
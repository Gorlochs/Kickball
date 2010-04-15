//
//  MGTwitterEngine+Search.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 10/9/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#include "MGTwitterEngineAddIn.h"

enum {
    MGTwitterSearchManage = 10,
    MGTwitterSearchSave = 11,
    MGTwitterSearchDestroy = 12,
};

@interface MGTwitterEngine (Search)

- (NSString *)getSearchSavedResult:(int)pageNum count:(int)count;

//- (NSString *)getSearchSavedResultById:(int)queryID;
- (NSString *)getSearchSavedResultById:(NSString*)queryID;

- (NSString *)searchSaveQuery:(NSString *)query;

//- (NSString *)searchDestroyQuery:(int)queryID;
- (NSString *)searchDestroyQuery:(NSString*)queryID;

@end

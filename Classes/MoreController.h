//
//  MoreController.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchProvider;

@interface MoreController : UITableViewController {
    NSMutableArray      *_moreItems;
    SearchProvider      *_searchProvider;
	BOOL				isSavedSearchesLoaded;
}

@property (nonatomic, assign) SearchProvider *searchProvider;

@end

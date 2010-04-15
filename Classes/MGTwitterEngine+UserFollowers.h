//
//  MGTwitterEngine+UserFollowers.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#include "MGTwitterEngineAddIn.h"

@interface MGTwitterEngine (UserFollowers)

- (NSString *)getFollowersForUser:(NSString *)username lite:(BOOL)flag;

@end

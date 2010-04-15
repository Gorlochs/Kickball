//
//  MGTwitterEngine+UserFollowers.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "MGTwitterEngine+UserFollowers.h"

@implementation MGTwitterEngine (UserFollowers)

- (NSString *)getFollowersForUser:(NSString *)username lite:(BOOL)flag
{
    NSString *path = [NSString stringWithFormat:@"statuses/followers/%@.%@", username, API_FORMAT];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!flag) {
        [params setObject:@"true" forKey:@"lite"]; // slightly bizarre, but correct.
    }
    
    return [self _sendRequestWithMethod:nil path:path 
                        queryParameters:params 
                                   body:nil 
                            requestType:MGTwitterUser 
                           responseType:MGTwitterUsers];
}

@end

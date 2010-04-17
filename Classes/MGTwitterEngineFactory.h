//
//  MGTwitterEngineFactory.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/5/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserAccount, XAuthTwitterEngine;
@interface MGTwitterEngineFactory : NSObject {
}

+ (MGTwitterEngineFactory*)factory;

+ (XAuthTwitterEngine*)createTwitterEngineForCurrentUser:(id)del;

- (XAuthTwitterEngine*)createTwitterEngineForUserAccount:(UserAccount*)account delegate:(id)del;

- (NSDictionary*)createTwitterAuthorizationFields:(UserAccount*)account;

@end

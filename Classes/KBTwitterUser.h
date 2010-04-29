//
//  KBTwitterUser.h
//  Kickball
//
//  Created by Shawn Bernard on 4/28/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KBTwitterUser : NSObject {
    NSString *screenName;
    NSString *fullName;
    NSString *profileImageUrl;
    NSNumber *userId;
    
    NSDictionary *dict;
}

@property (nonatomic, retain) NSString *screenName;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *profileImageUrl;
@property (nonatomic, retain) NSNumber *userId;

- (id) initWithDictionary:(NSDictionary*)userDictionary;

@end

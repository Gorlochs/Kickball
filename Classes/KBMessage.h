//
//  KBMessage.h
//  Kickball
//
//  Created by Shawn Bernard on 12/26/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KBMessage : NSObject {
    NSString *mainTitle;
    NSString *subtitle;
    NSString *message;
    BOOL isError;
}

@property (nonatomic, retain) NSString *mainTitle;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *message;
@property (nonatomic) BOOL isError;

- (id) initWithMember: (NSString*)maintitle andMessage:(NSString*)msg;
- (id) initWithMember: (NSString*)maintitle andMessage:(NSString*)msg isError:(BOOL)isAnError;
- (id) initWithMember: (NSString*)maintitle andSubtitle:(NSString*)subTitle andMessage:(NSString*)msg;

@end

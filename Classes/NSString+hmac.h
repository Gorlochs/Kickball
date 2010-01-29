//
//  NSString+hmac.h
//  Kickball
//
//  Created by Jim Cushing on 1/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (HMACAdditions)
	- (NSString *)hmacSha1:(NSString *)secret;

@end

//
//  NSString+hmac.m
//  Kickball
//
//  Created by Jim Cushing on 1/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+hmac.h"
#import "hmac.h"


@implementation NSString (HMACAdditions)

- (NSString *)hmacSha1:(NSString *)secret {
	NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *textData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char result[20];
	hmac_sha1((unsigned char *)[textData bytes], [textData length], (unsigned char *)[secretData bytes], [secretData length], result);
	
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15],
			result[16], result[17], result[18], result[19]
			];	
}
@end

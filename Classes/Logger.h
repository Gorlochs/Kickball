//
//  Logger.h
//
//  Created by Sergey Shkrabak on 10/16/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ISLog(msg)                  [[Logger logger] log:(msg) className:NSStringFromClass([self class]) methodName:NSStringFromSelector(_cmd) atLine:__LINE__];
#define ISLogLine(msg)              [[Logger logger] log:(msg) marker:YES]

#ifdef TRACE
	#define YFLog(format, ...);				NSLog(format, ## __VA_ARGS__);
#else
	#define YFLog(format, ...); 
#endif

@interface Logger : NSObject {
    NSMutableData *_data;
    NSString *_path;
}

+ (Logger*)logger;

- (void)log:(NSString*)str;

- (void)log:(NSString*)str marker:(BOOL)isMarker;

- (void)log:(NSString*)message className:(NSString*)nameOfClass methodName:(NSString*)nameOfMethod atLine:(unsigned)line;

- (NSString *)path;

- (void)clear;

@end

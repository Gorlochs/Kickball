//
//  Logger.m
//
//  Created by Sergey Shkrabak on 10/16/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "Logger.h"
#include "config.h"

@implementation Logger

+ (Logger*)logger
{
    static Logger *logger = nil;
    if (logger == nil)
        logger = [[Logger alloc] init];
    return logger;
}

+ (NSString*)titleBlock
{
    NSDateFormatter *formater = [[[NSDateFormatter alloc] init] autorelease];
    
    [formater setDateStyle:NSDateFormatterShortStyle];
    [formater setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *dt = [formater stringFromDate:[NSDate date]];
    
    NSMutableString *title = [NSMutableString string];
    
    [title appendString:@"----------------------------------------------\n"];
    [title appendString:@" yfrog\n"];
    [title appendFormat:@" %@\n", dt];
    [title appendString:@"----------------------------------------------\n"];
    
    return title;
}

- (id)init
{
    self = [super init];
    
    _data = [[NSMutableData alloc] init];
    _path = @"/Users/shawnbernard/Desktop/yfrog.log";
#ifndef DEBUG
    _path = @"/tmp/isuploader.log";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) 
    {
        NSString *userDocumentsPath = [paths objectAtIndex:0];
        _path = [[NSString stringWithFormat:@"%@/yfrog.log", userDocumentsPath] retain];
        YFLog(_path);
    }
#endif
    [self log:[Logger titleBlock]];
    
    return self;
}

- (void)dealloc
{
    [_path release];
    [_data release];
    [super dealloc];
}

- (void)log:(NSString*)str
{
    [self log:str marker:NO];
}

- (void)log:(NSString*)str marker:(BOOL)isMarker
{
    @try
    {
        /*
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:_path];
        if (file == nil)
        {
            [[str dataUsingEncoding:NSUTF8StringEncoding] writeToFile:_path atomically:YES];
        }
        else
        {
            [file seekToEndOfFile];
            if (isMarker)
                [file writeData:[@"--> " dataUsingEncoding:NSUTF8StringEncoding]];
            [file writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            [file writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [file synchronizeFile];
            [file closeFile];
        }
        */
        YFLog(str);
    }
    @catch (...) {
        YFLog(@"Could not write log");
    }
}

- (void)log:(NSString*)message className:(NSString*)nameOfClass methodName:(NSString*)nameOfMethod atLine:(unsigned)line
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSString *tm = [dateFormatter stringFromDate:[NSDate date]];
    NSString *str = [NSString stringWithFormat:@"[%@] %@: %@:[%i] - %@", tm, nameOfClass, nameOfMethod, line, message];
    [self log:str marker:YES];
}

- (NSString *)path
{
    return [[_path retain] autorelease];
}

- (void)clear
{
    NSString *head = [Logger titleBlock];
    [[head dataUsingEncoding:NSUTF8StringEncoding] writeToFile:_path atomically:YES];
}

@end

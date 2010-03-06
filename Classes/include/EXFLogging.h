/*
 *  logging.h
 * 
 *
 *  Created by steve woodcock on 28/02/2008.
 *  Copyright 2008. All rights reserved.
 *
 */

// Logging.h
extern BOOL gLogging;
#define Debug(FMT,...)  if(1 == 2) ; else  NSLog(@"DEBUG: " FMT, ##__VA_ARGS__)
#define Warn(FMT,...)   NSLog(@"WARNING: " FMT, ##__VA_ARGS__)
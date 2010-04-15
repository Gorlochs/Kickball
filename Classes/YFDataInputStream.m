// Copyright (c) 2010 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "YFDataInputStream.h"

@implementation YFDataInputStream

@synthesize dataSource;

- (id)init
{
	self = [super init];
	if (nil != self)
	{
		totalLength = 0;
		dataChunkLocation = 0;
		dataChunkIndex = 0;
		status = NSStreamStatusNotOpen;
		delegate = nil;
		dataSource = nil;		
	}
	
	return self;
}

#pragma mark Input Stream implementation
- (NSInteger)read:(uint8_t *)aBuffer maxLength:(NSUInteger)aLength
{
	if (dataChunkIndex >= [[self.dataSource dataContainer] count])
	{
		status = NSStreamStatusAtEnd;
		return 0;
	}
	
	if (![self hasBytesAvailable])
	{
		status = NSStreamStatusAtEnd;
		return 0;
	}	
	
	NSData *dataChunk = [[self.dataSource dataContainer] objectAtIndex:dataChunkIndex];
	if (nil == dataChunk)
	{
		status = NSStreamStatusError;
		return 0;
	}

	status = NSStreamStatusReading;
	NSInteger readDataLength = 0;
	NSRange dataRange = NSMakeRange(0, 0);
	if (dataChunkLocation + aLength < [dataChunk length])
	{
		//      |
		//		v
		// |----<----->-----|
		dataRange = NSMakeRange(dataChunkLocation, aLength);
		readDataLength = aLength;
		dataChunkLocation += readDataLength;
	}
	else
	{
		//				|
		//				v
		// |------------<---|->
		NSUInteger theLength = [dataChunk length] - dataChunkLocation;
		dataRange = NSMakeRange(dataChunkLocation, theLength);
		readDataLength = theLength;
		dataChunkLocation = 0;
		dataChunkIndex++;
	}
	
	[dataChunk getBytes:aBuffer range:dataRange];
	
	return readDataLength;
}

- (BOOL)hasBytesAvailable
{
	if (dataChunkIndex < [[self.dataSource dataContainer] count])
	{
		NSData *dataChunk = [[self.dataSource dataContainer] objectAtIndex:dataChunkIndex];
		if (dataChunkLocation < [dataChunk length])
		{
			return YES;
		}
	}
	
	status = NSStreamStatusAtEnd;
    return NO;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

- (NSUInteger)length
{
	if (0 == totalLength)
	{
		NSInteger index = 0;
		for (;index < [[self.dataSource dataContainer] count]; ++index)
		{
			NSData *dataChunk = [[self.dataSource dataContainer] objectAtIndex:index];
			totalLength += [dataChunk length];
		}		
	}
	return totalLength;
}

#pragma mark Stream implementation
- (void)open
{
    status = NSStreamStatusOpen;
}

- (void)close
{
    status = NSStreamStatusClosed;
}

- (id)delegate 
{
    return delegate;
}

- (void)setDelegate:(id)aDelegate 
{
    delegate = aDelegate;
}

- (id)propertyForKey:(NSString *)key 
{
    return nil;
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key 
{
    return NO;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode 
{
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode 
{
}

- (NSStreamStatus)streamStatus 
{
    return status;
}

- (NSError *)streamError 
{
    return nil;
}

- (void)_scheduleInCFRunLoop:(NSRunLoop *)inRunLoop forMode:(id)inMode
{
}

- (void)_setCFClientFlags:(CFOptionFlags)inFlags
			callback:(CFReadStreamClientCallBack)inCallback context:(CFStreamClientContext) inContext
{
}

@end

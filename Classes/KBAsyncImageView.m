/*
Copyright 2009 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binaryform must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided withthe distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "KBAsyncImageView.h"
#import "Utilities.h"


// Adapted from Mark J. KBAsyncImageView
// http://www.markj.net/iphone-asynchronous-table-image/

@implementation KBAsyncImageView

@synthesize onReady;
@synthesize target;

- (void)dealloc {
	[connection cancel];
	[connection release];
	[data release];
	[super dealloc];
}

- (void)loadImageFromURL:(NSURL*)url withRoundedEdges:(BOOL)rounded{
	if([[url absoluteString] length] == 0) {
		return;
	}
	roundEdges = rounded;
	
	if (connection!=nil) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	if (data!=nil) {
		[data release];
		data = nil;
	}
	NSURLRequest* request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; }
	[data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	[connection release];
	connection=nil;
	[self imageReady: data];
	[data release];
	data=nil;
}

- (void)imageReady:(NSData*)imgData {
	UIImage *img = [UIImage imageWithData: imgData];
	if(roundEdges) {
		self.image = [Utilities makeRoundCornerImage:img cornerwidth:8 cornerheight:8];
	} else {
        self.image = img;
    }
	self.frame = self.bounds;
	
	[self setNeedsLayout];	
	if(target != nil && onReady != nil) {
		NSMethodSignature * sig = nil;
		sig = [[target class] instanceMethodSignatureForSelector: onReady];
		
		NSInvocation * myInvocation = nil;
		myInvocation = [NSInvocation invocationWithMethodSignature: sig];
	    [myInvocation setArgument: &self atIndex: 2];
		[myInvocation setTarget: target];
		[myInvocation setSelector: onReady];
		[myInvocation invoke];
	}
}

@end
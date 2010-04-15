// Copyright (c) 2009 Imageshack Corp.
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

#import "yFrogImageUploader.h"
#import "TweetterAppDelegate.h"
#import "MGTwitterEngineFactory.h"
#import "LocationManager.h"
#include "util.h"
#include "config.h"
#import "MGTwitterEngine.h"

#define		JPEG_CONTENT_TYPE			@"image/jpeg"
#define		MP4_CONTENT_TYPE			@"video/mp4"
#define		RETRIES_NUMBER_LIMIT		5
const NSTimeInterval kTimerRetryInterval = 5.0;
NSString *const kGatewayTimeOutError = @"504 Gateway Time-out";

@interface ImageUploader()

- (NSString *)getApiURL;

@end

@implementation ImageUploader

@synthesize connection;
@synthesize contentXMLProperty;
@synthesize newURL;
@synthesize userData;
@synthesize delegate;
@synthesize contentType;
@synthesize uploadDataContainer;

-(id)init
{
	self = [super init];
	if(self)
	{
		canceled = NO;
		scaleIfNeed = NO;
		isHeaderTag = NO;
		isPresentGatewayError = NO;
		retriesCounter = 0;
		imageDimension = 0;
		imageRotationAngle = 0;
	}
	return self;
}

- (void)setVideoUploadEngine:(ISVideoUploadEngine*)engine
{
    if (videoUploadEngine != engine)
    {
        //stop and release current upload process if current is exists
        if (videoUploadEngine)
        {
            [videoUploadEngine cancel];
            [videoUploadEngine release];
        }
        //set new ISVideoUploadEngine object
        videoUploadEngine = [engine retain];
    }
}

-(void)dealloc
{
	YFLog(@"Image Uploader - DEALLOC");
		
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [videoUploadEngine release];
	[result release];
	[retryTimer release];
	
	self.delegate = nil;
	self.connection = nil;
	self.contentXMLProperty = nil;
	self.newURL = nil;
	self.userData = nil;
	self.contentType = nil;
	self.uploadDataContainer = nil;
	
	[super dealloc];
}

- (void)postData:(NSData *)anImageData
{
	if (nil == anImageData || canceled)
	{
		return;
	}
		
	if(!self.contentType)
	{
		YFLog(@"Content-Type header was not setted\n");
		return;
	}
	
	//NSString* login = [MGTwitterEngine username];
	//NSString* pass = [MGTwitterEngine password];
	
    UserAccount *account = [[AccountManager manager] loggedUserAccount];
    MGTwitterEngineFactory *factory = [MGTwitterEngineFactory factory];
    NSDictionary *authFields = [factory createTwitterAuthorizationFields:account];
    if (nil == authFields)
	{
		[delegate uploadedImage:nil sender:self];
        return;
    }
		
	NSString *boundary = [NSString stringWithFormat:@"%ld__%ld__%ld", random(), random(), random()];
	
	NSMutableData *headerData = [NSMutableData data];
	
    for (NSString *key in [authFields allKeys])
	{
        NSString *value = [authFields objectForKey:key];
		if (nil != value)
		{
			[headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[headerData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
			[headerData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
		}
    }
	
	[headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [headerData appendData:[@"Content-Disposition: form-data; name=\"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [headerData appendData:[kTweeteroDevKey dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (0 < imageDimension)
	{
		[headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[@"Content-Disposition: form-data; name=\"optimage\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[[NSString stringWithString:@"1"] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[@"Content-Disposition: form-data; name=\"optsize\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[[NSString stringWithFormat:@"%dx%d", imageDimension, imageDimension] dataUsingEncoding:NSUTF8StringEncoding]];				
	}
	
	if (0 < imageRotationAngle)
	{
		[headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[@"Content-Disposition: form-data; name=\"rotate\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[[NSString stringWithFormat:@"%d", imageRotationAngle] dataUsingEncoding:NSUTF8StringEncoding]];		
	}
	
	if([[LocationManager locationManager] locationDefined])
	{
        [headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[@"Content-Disposition: form-data; name=\"tags\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[headerData appendData:[[NSString stringWithFormat:@"geotagged, geo:lat=%+.6f, geo:lon=%+.6f",
					[[LocationManager locationManager] latitude],
					[[LocationManager locationManager] longitude]] dataUsingEncoding:NSUTF8StringEncoding]];
	}	
	
	[headerData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	NSString* fileHeader = [NSString stringWithFormat:
				@"--%@\r\n"
				"Content-Disposition: form-data; name=\"fileupload\"; filename=\"iPhoneMedia\"\r\n"
				"Content-Type: %@\r\n"
				"Content-Transfer-Encoding: binary; \r\n\r\n",
				boundary, self.contentType];
	[headerData appendData:[fileHeader dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *bodyData = anImageData;
	NSData *endData = [[NSString stringWithFormat:@"\r\n--%@--\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *datasArray = [NSArray arrayWithObjects:headerData, bodyData, endData, nil];
	
	self.uploadDataContainer = datasArray;
	YFDataInputStream *stream = [[YFDataInputStream alloc] init];
	stream.dataSource = self;
	
	NSURL *url = [NSURL URLWithString:[self getApiURL]];
	NSMutableURLRequest *request = tweeteroMutableURLRequest(url);
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies:NO];
	[request setTimeoutInterval:HTTPUploadTimeout];
	[request setHTTPMethod:@"POST"];
	[request setHTTPShouldHandleCookies:NO];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-type"];
    [request setValue:[NSString stringWithFormat:@"%d", [stream length]] forHTTPHeaderField:@"Content-length"];
	
	[request setHTTPBodyStream:stream];
	[stream release];

	[self setImageDimension:0];
	[self setImageRotationAngle:0];
	
    [delegate uploadedDataSize:[stream length]];
		
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection)
	{
		result = [[NSMutableData data] retain];
	}
	else
	{
		[delegate uploadedImage:nil sender:self];
		return;
	}
	
	[TweetterAppDelegate increaseNetworkActivityIndicator];
}

- (void)postData:(NSData*)data contentType:(NSString*)mediaContentType
{
	self.contentType = mediaContentType;
	[self postData:data contentType:self.contentType];
}


- (void)postJPEGData:(NSData*)imageJPEGData delegate:(id <ImageUploaderDelegate>)dlgt userData:(id)data
{
	self.delegate = dlgt;
	self.userData = data;
	
	if(!imageJPEGData)
	{
		[delegate uploadedImage:nil sender:self];
		return;
	}

	self.contentType = JPEG_CONTENT_TYPE;
	[self postData:imageJPEGData];
}

- (void)postMP4DataWithUploadEngine:(ISVideoUploadEngine*)engine delegate:(id <ImageUploaderDelegate>)dlgt userData:(id)data
{
	self.delegate = dlgt;
	self.userData = data;

	[TweetterAppDelegate increaseNetworkActivityIndicator];
    
    UserAccount *account = [[AccountManager manager] loggedUserAccount];
    MGTwitterEngineFactory *factory = [MGTwitterEngineFactory factory];
    NSDictionary *authFields = [factory createTwitterAuthorizationFields:account];
    if (authFields) {
        NSString *val = [authFields objectForKey:@"a_username"];
        if (val)
            engine.username = val;
        val = [authFields objectForKey:@"a_password"];
        if (val)
            engine.password = val;
        else {
            val = [authFields objectForKey:@"a_verify_url"];
            if (val)
                engine.verifyUrl = val;
        }
    }
    if (![engine upload])
        [delegate uploadedImage:nil sender:self];
    else
        [self setVideoUploadEngine:engine];
}

- (void)postMP4DataWithPath:(NSString*)path delegate:(id <ImageUploaderDelegate>)dlgt userData:(id)data
{
	if(!path)
	{
		[delegate uploadedImage:nil sender:self];
		return;
	}
	
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing postMP4DataWithPath:delegate: method...");
	YFLog(@"	YFrog_DEBUG: Creating Video upload engine");
#endif
	
    ISVideoUploadEngine *engine = [[ISVideoUploadEngine alloc] initWithPath:path delegate:self];
    [self postMP4DataWithUploadEngine:engine delegate:dlgt userData:data];
    [engine release];
}

- (void)postMP4Data:(NSData*)movieData delegate:(id <ImageUploaderDelegate>)dlgt userData:(id)data
{
	if(!movieData)
	{
		[delegate uploadedImage:nil sender:self];
		return;
	}
    ISVideoUploadEngine *engine = [[ISVideoUploadEngine alloc] initWithData:movieData delegate:self];
    [self postMP4DataWithUploadEngine:engine delegate:dlgt userData:data];
    [engine release];
}

- (void)postData:(NSData*)anImageData delegate:(id <ImageUploaderDelegate>)dlgt userData:(id)data
{
	self.delegate = dlgt;
	self.userData = data;
	self.contentType = JPEG_CONTENT_TYPE;
	
	[self postData:anImageData];
}

- (void)setImageDimension:(int)inNewDimension
{
	imageDimension = inNewDimension;
}

- (void)setImageRotationAngle:(int)inNewAngle
{
	imageRotationAngle = inNewAngle;
}

#pragma mark NSURLConnection delegate methods
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [result setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [result appendData:data];
}

- (void) connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
	[connection release];
	connection = nil;
	[result release];
	result = nil;
	
	if (retriesCounter < RETRIES_NUMBER_LIMIT)
	{
		retriesCounter++;
		isHeaderTag = NO;
		isPresentGatewayError = NO;
		retryTimer = [[NSTimer scheduledTimerWithTimeInterval:kTimerRetryInterval target:self
					selector:@selector(retryTimerFired:) userInfo:nil repeats:NO] retain];
		return;
	}
	
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	[delegate uploadedImage:nil sender:self];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten 
                                      totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [delegate uploadedProccess:bytesWritten totalBytesWritten:totalBytesWritten];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) 
        elementName = qName;
	
	if ([elementName isEqualToString:@"h1"])
		isHeaderTag = YES;

    if ([elementName isEqualToString:@"yfrog_link"])
		self.contentXMLProperty = [NSMutableString string];
	else
		self.contentXMLProperty = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName)
        elementName = qName;
    
    if ([elementName isEqualToString:@"yfrog_link"])
	{
        self.newURL = [self.contentXMLProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[parser abortParsing];
	}
	else if ([elementName isEqualToString:@"h1"])
	{
		isHeaderTag = NO;
		if (isPresentGatewayError)
		{
			[parser abortParsing];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.contentXMLProperty)
		[self.contentXMLProperty appendString:string];
	else if (isHeaderTag)
	{
		if([string rangeOfString:kGatewayTimeOutError options:NSCaseInsensitiveSearch].location != NSNotFound)
		{
			isPresentGatewayError = YES;
		}
	}	
}

- (void) connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	[connection release];
	connection = nil;
	
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
    
	YFLog(@"Image Uploader Result: %@", [[[NSString alloc] initWithData:result encoding:4] autorelease]);
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:result];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[result release];
	result = nil;

	if (isPresentGatewayError && retriesCounter < RETRIES_NUMBER_LIMIT)
	{
		retriesCounter++;
		isHeaderTag = NO;
		isPresentGatewayError = NO;
		retryTimer = [[NSTimer scheduledTimerWithTimeInterval:kTimerRetryInterval target:self
					selector:@selector(retryTimerFired:) userInfo:nil repeats:NO] retain];
		return;
	}
	
	[delegate uploadedImage:self.newURL sender:self];
}

- (void)cancel
{
	canceled = YES;
	if(connection)
	{
		[connection cancel];
		[connection release];
		connection = nil;
		
		[TweetterAppDelegate decreaseNetworkActivityIndicator];
	}
	[self setVideoUploadEngine:nil];
	[delegate uploadedImage:nil sender:self];
}

- (BOOL)canceled
{
	return canceled;
}

- (void)retryTimerFired:(NSTimer *)aTimer
{
    if (nil != retryTimer)
    {
        [retryTimer invalidate];
        [retryTimer release];
        retryTimer = nil;
    }
	
	[connection cancel];
	[connection release];
	connection = nil;
	
	[contentXMLProperty release];
	contentXMLProperty = nil;
	
	[newURL release];
	newURL = nil;
	
	[userData release];
	userData = nil;
	
	[contentType release];
	contentType = nil;
	
	[delegate imageUploadDidFailedBySender:self];
}

- (NSString *)getApiURL
{
	const NSInteger theServerCount = 9;
    static NSInteger theCurrentServerImage = 1;
    
    NSInteger theServerIndex = (random() % theServerCount) + 1;
    if (theServerIndex == theCurrentServerImage)
	{
        theServerIndex = (random() % theServerCount) + 1;
	}

    theCurrentServerImage = theServerIndex;
		
    return [NSString stringWithFormat:@"http://load%d.imageshack.us/upload_api.php", theServerIndex];
}

#pragma mark ISVideoUploadEngine Delegate
- (void)didStartUploading:(ISVideoUploadEngine *)engine totalSize:(NSUInteger)size
{
    [delegate uploadedDataSize:size];
}

- (void)didFinishUploading:(ISVideoUploadEngine *)engine videoUrl:(NSString *)link
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	[delegate uploadedImage:link sender:self];
}

- (void)didFailWithErrorMessage:(ISVideoUploadEngine *)engine errorMessage:(NSString *)error
{
	[TweetterAppDelegate decreaseNetworkActivityIndicator];
	[delegate uploadedImage:nil sender:self];
}

- (void)didFinishUploadingChunck:(ISVideoUploadEngine *)engine uploadedSize:(NSUInteger)totalUploadedSize totalSize:(NSUInteger)size
{
    [delegate uploadedProccess:totalUploadedSize totalBytesWritten:totalUploadedSize];
}

- (void)didStopUploading:(ISVideoUploadEngine *)engine
{
}

- (void)didResumeUploading:(ISVideoUploadEngine *)engine
{
}

#pragma mark YFDataInputStream DataSource
- (NSArray *)dataContainer
{
	return self.uploadDataContainer;
}

@end

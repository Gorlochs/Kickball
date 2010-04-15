//
//  ISUploadEngine.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/30/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "ISVideoUploadEngine.h"
#import "LocationManager.h"
#include "util.h"
#include "config.h"

#define IsValidStatusCode(s)        (((s) == 200) || ((s) == 201) || ((s) == 202))

#define IMAGESHACK_API_START        @"http://render.imageshack.us/renderapi/start"

#define ImageInfoRootName           @"imginfo"
#define UploadInfoRootName          @"uploadInfo"
#define UploadInfoLinkName          @"link"
#define UploadInfoPutName           @"putURL"
#define UploadInfoGetLengthName     @"getlengthURL"
#define ErrorRootName               @"error"
#define ErrorCodeName               @"code"

const NSTimeInterval kDefaultRetryInterval = 5.0;

@interface ISVideoUploadEngine (Private)

- (void)doPhase:(int)phaseCode;
- (void)sendInitData;
- (void)uploadNextChunk;
- (void)resumeUpload;
- (void)clearResult;
- (BOOL)openConnection:(NSURLRequest *)request;
- (NSString *)errorMessage;
- (NSData*)dataWithRange:(NSRange)range;
- (unsigned long long)dataSize;
- (void)retryUpload:(BOOL)isSession;
- (void)retryOrProcessError:(NSError *)error;
- (void)closeConnection;
- (void)destroyRetryTimer;
- (BOOL)canRetryChunkSession;
- (void)retryChunkSession;
@end

@implementation ISVideoUploadEngine

@synthesize username;
@synthesize password;
@synthesize uploadData;
@synthesize linkUrl;
@synthesize putUrl;
@synthesize getLengthUrl;
@synthesize verifyUrl;
@synthesize path;
@synthesize isOpened;

- (id)init
{
    if (self = [super init])
    {
        boundary = [[NSString stringWithFormat:@"------%ld__%ld__%ld", random(), random(), random()] retain];
        connection = nil;
        result = [[NSMutableData alloc] init];
        phase = ISUploadPhaseNone;
        path = nil;
        uploadData = nil;
        internalDataSize = 0;
    }
    return self;
}

- (id)initWithData:(NSData *)theData delegate:(id<ISVideoUploadEngineDelegate>) dlgt
{
    if ((self = [self init]))
    {
        delegate = dlgt;
        uploadData = [theData retain];
    }
    return self;
}

- (id)initWithPath:(NSString*)aPath delegate:(id<ISVideoUploadEngineDelegate>) dlgt
{
    if (self = [self init])
    {
#ifdef TRACE
		YFLog(@"YFrog_DEBUG: Executing initWithPath:delegate: method...");
		YFLog(@"	YFrog_DEBUG: A path of the video file %@", aPath);
#endif
		
        self.path = aPath;
        delegate = dlgt;
    }
    return self;
}

- (void)dealloc
{
    self.path = nil;
    self.linkUrl = nil;
    self.putUrl = nil;
    self.getLengthUrl = nil;
    self.verifyUrl = nil;
    if (connection)
        [connection release];
    [result release];
    [uploadData release];
	[boundary release];
    [super dealloc];
}

- (BOOL)upload
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Starting Video Upload...");
	YFLog(@"	YFrog_DEBUG: Current Phase is %d", phase);
#endif
	
    BOOL success = NO;
    if (phase == ISUploadPhaseNone)
    {
		sessionCount = 0;
		retryCounter = 0;
        [self doPhase:ISUploadPhaseStart];
        success = YES;
    }
    return success;
}

// Cancel uploading process
- (void)cancel
{
    phase = ISUploadPhaseNone;
    currentDataLocation = 0;
    if (connection) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    [self release];
}

- (BOOL)fromFile
{
    return (uploadData == nil && self.path != nil);
}

#pragma mark NSURLConnection connection callbacks
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing connection:didFailWithError: method...");
	YFLog(@"	YFrog_DEBUG: Error description %@", [error description]);
#endif
	
    [delegate didStopUploading:self];
    
    // Resume upload
    [self retryOrProcessError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing connectionDidFinishLoading: method...");
	YFLog(@"	YFrog_DEBUG: Status code is %d", statusCode);
	YFLog(@"	YFrog_DEBUG: Current phase is %d", phase);
#endif
	
    if (IsValidStatusCode(statusCode))
    {
        if (phase == ISUploadPhaseResumeUpload)
        {
			[delegate didResumeUploading:self];
            [self doPhase:ISUploadPhaseUploadData];            
        }
		else
		{
			if (phase == ISUploadPhaseUploadData && statusCode == 202)
            {
				[delegate didFinishUploadingChunck:self uploadedSize:currentDataLocation totalSize:[self dataSize]];
                [self uploadNextChunk];
            }
			else
			{
				NSXMLParser *parser = [[NSXMLParser alloc] initWithData:result];

				[parser setDelegate:self];
				[parser setShouldProcessNamespaces:NO];
				[parser setShouldReportNamespacePrefixes:NO];
				[parser setShouldResolveExternalEntities:NO];
				[parser parse];
				[parser release];
				
				[self clearResult];
			}
		}
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"yFrogVideoUploadEngine" code:statusCode userInfo:nil];
        [self retryOrProcessError:error];
    }
}

#pragma mark NSURLConnection data receive
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing connection:didReceiveResponse: method...");
	YFLog(@"	YFrog_DEBUG: Received responce %@", [response description]);
#endif			

    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*)response;
        statusCode = [httpResp statusCode];
        
#ifdef TRACE
		YFLog(@"	YFrog_DEBUG: Responce status code is: %d", statusCode);
#endif
		
//        if (phase == ISUploadPhaseResumeUpload)
//        {
//        }
//        else if (phase == ISUploadPhaseUploadData && statusCode == 202)
//        {
//            [delegate didFinishUploadingChunck:self uploadedSize:currentDataLocation totalSize:[self dataSize]];
//            [self uploadNextChunk];
//        }
    }
    [self clearResult];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing connection:didReceiveData: method...");
	YFLog(@"	YFrog_DEBUG: Received data is %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	YFLog(@"	YFrog_DEBUG: Current Phase is %d", phase);
#endif	
	
    if (phase == ISUploadPhaseResumeUpload)
    {
        //Parse the uploaded chunck size
        NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        currentDataLocation = [value intValue];
        [value release];
        //Call the delegate method
        [delegate didResumeUploading:self];
        [self doPhase:ISUploadPhaseUploadData];
    }
    else
    {
        [result appendData:data];
    }
}

#pragma mark Parser functions
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName compare:UploadInfoRootName] == NSOrderedSame)
    {
        self.linkUrl = [attributeDict objectForKey:UploadInfoLinkName];
        self.putUrl = [attributeDict objectForKey:UploadInfoPutName];
        self.getLengthUrl = [attributeDict objectForKey:UploadInfoGetLengthName];
    }
    else if ([elementName compare:ErrorRootName] == NSOrderedSame)
    {
        id code = [attributeDict objectForKey:ErrorCodeName];
        if (code)
            statusCode = [code intValue];
    }
    else if ([elementName compare:ImageInfoRootName] == NSOrderedSame)
    {
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName compare:UploadInfoRootName] == NSOrderedSame)
    {
        [self doPhase:ISUploadPhaseUploadData];
    }
    else if ([elementName compare:ErrorRootName] == NSOrderedSame)
    {
        [self doPhase:ISUploadPhaseProcessError];
    }
    else if ([elementName compare:ImageInfoRootName] == NSOrderedSame)
    {
        [self doPhase:ISUploadPhaseFinish];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

@end

@implementation ISVideoUploadEngine (Private)

- (void)doPhase:(int)phaseCode;
{
	phase = phaseCode;
	
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing doPhase method...");
	YFLog(@"	YFrog_DEBUG: Current Phase is %d", phase);
#endif

    switch (phase)
    {
        case ISUploadPhaseStart:
            [self retain];
            [self sendInitData];
            break;
        case ISUploadPhaseUploadData:
            //[delegate didStartUploading:self totalSize:[uploadData length]];
            [delegate didStartUploading:self totalSize:[self dataSize]];
            [self uploadNextChunk];
            break;
        case ISUploadPhaseResumeUpload:
            [self resumeUpload];
            break;
        case ISUploadPhaseProcessError:
            [delegate didFailWithErrorMessage:self errorMessage:[self errorMessage]];
            currentDataLocation = 0;
            phase = ISUploadPhaseNone;
            [self release];
            break;
        case ISUploadPhaseFinish:
            //[delegate didFinishUploadingChunck:self uploadedSize:currentDataLocation totalSize:[uploadData length]];
            [delegate didFinishUploadingChunck:self uploadedSize:currentDataLocation totalSize:[self dataSize]];
            [delegate didFinishUploading:self videoUrl:self.linkUrl];
            currentDataLocation = 0;
            phase = ISUploadPhaseNone;
            [self release];
    }
}

- (void)sendInitData
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing sendInitData method...");
	YFLog(@"	YFrog_DEBUG: Current Phase is %d", phase);
#endif	
	
    NSMutableData *body = [NSMutableData data];
    
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Disposition: form-data; name=\"filename\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"iPhoneMedia" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[kTweeteroDevKey dataUsingEncoding:NSUTF8StringEncoding]];
    
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Disposition: form-data; name=\"t_username\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[self.username dataUsingEncoding:NSUTF8StringEncoding]];
	
    if (self.password != nil) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"t_password\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[self.password dataUsingEncoding:NSUTF8StringEncoding]];
    } else if (self.verifyUrl) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"auth\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"oauth" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"t_verify_url\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[self.verifyUrl dataUsingEncoding:NSUTF8StringEncoding]];
    }

	if([[LocationManager locationManager] locationDefined])
	{
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Disposition: form-data; name=\"tags\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"geotagged, geo:lat=%+.6f, geo:lon=%+.6f", 
                           [[LocationManager locationManager] latitude], [[LocationManager locationManager] longitude]] 
                          dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *apiUrl = [NSURL URLWithString:IMAGESHACK_API_START];
    NSMutableURLRequest *request = tweeteroMutableURLRequest(apiUrl);
	NSString *multipartContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:HTTPUploadTimeout];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setValue:multipartContentType forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:body];
    
    [self clearResult];
    currentDataLocation = 0;
	
#ifdef TRACE
	YFLog(@"	YFrog_DEBUG: From sendInitData: Created HTTP request with body:");
	YFLog(@"	YFrog_DEBUG: %@", [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease]);
#endif	
    
    BOOL validConnection = [self openConnection:request];
    if (!validConnection || !self.isOpened)
	{
        [self doPhase:ISUploadPhaseProcessError];
	}
}

- (void)uploadNextChunk
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing uploadNextChunk method...");
	YFLog(@"	YFrog_DEBUG: Current Phase is %d", phase);
#endif	
	
    NSRange range = {0, 31*1024+512}; // 31.5 Kb

    range.location = currentDataLocation;
    //if ([uploadData length] <= range.location)
    unsigned long long size = [self dataSize];
    if (size <= range.location)
        return;
    
    //if (([uploadData length] - range.location) < range.length)
    if ((size - range.location) < range.length)
        range.length = size - range.location;
    
    //NSData *dataChunck = [uploadData subdataWithRange:range];
    NSData *dataChunck = [self dataWithRange:range];

    //NSString *contentLength = [NSString stringWithFormat:@"%d", [uploadData length]];
    NSString *contentLength = [NSString stringWithFormat:@"%d", size];
    //NSString *contentRange = [NSString stringWithFormat:@"bytes %d-%d/%d", range.location, range.location + range.length-1, [uploadData length]];
    NSString *contentRange = [NSString stringWithFormat:@"bytes %d-%d/%d", range.location, range.location + range.length-1, size];
    
    NSMutableURLRequest *request = tweeteroMutableURLRequest([NSURL URLWithString:self.putUrl]);
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:dataChunck];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:contentRange forHTTPHeaderField:@"Content-Range"];

#ifdef TRACE
	YFLog(@"	YFrog_DEBUG: Chank to upload %@", NSStringFromRange(range));
#endif
	
	[self closeConnection];
    
    BOOL validConnection = [self openConnection:request];
    if (!validConnection)
        [self doPhase:ISUploadPhaseProcessError];
    
    currentDataLocation += range.length;
}

- (void)resumeUpload
{
#ifdef TRACE
    YFLog(@"resumeUpload");
#endif	
	
    if (self.isOpened)
	{
        [self closeConnection];
	}
	
    if (self.getLengthUrl)
    {
#ifdef TRACE
		YFLog(@"Run get length connection");
#endif		

        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        
        [request setURL:[NSURL URLWithString:self.getLengthUrl]];
        [self openConnection:request];
    }
    
    if (!self.isOpened)
	{
        [self doPhase:ISUploadPhaseProcessError];
	}
}

- (void)clearResult
{
    [result setLength:0];
}

- (BOOL)canRetryChunkSession
{
#ifdef TRACE
    YFLog(@"Can Retry chunk session = %i", sessionCount);
#endif
    
    if (sessionCount++ < 3 && timer == nil)
	{
        return YES;
	}
	
    return NO;
}

- (void)retryChunkSession
{
#ifdef TRACE
    YFLog(@"Retry session");
#endif
	
    [self retryUpload:YES];
}

- (void)retryUpload:(BOOL)isSession
{
#ifdef TRACE
    YFLog(@"retry Upload");
#endif
	
    [self destroyRetryTimer];
    
    NSNumber *isSessionNumber = [NSNumber numberWithBool:isSession];
    timer = [[NSTimer scheduledTimerWithTimeInterval:kDefaultRetryInterval target:self
				selector:@selector(retryTimerFired:) userInfo:isSessionNumber repeats:NO] retain];
}

- (void)destroyRetryTimer
{
    if (nil != timer)
    {
        [timer invalidate];
        [timer autorelease];
        timer = nil;
    }
}

- (void)retryTimerFired:(NSTimer *)aTimer
{
#ifdef TRACE
    YFLog(@"retryTimerFired");
#endif
    
	NSNumber *isSession = [timer userInfo];
    [self destroyRetryTimer];
    if (nil != isSession && [isSession boolValue] == YES)
    {
        [self closeConnection];
        [self doPhase:ISUploadPhaseStart];
        [self release];
    }
    else
	{
        [self doPhase:ISUploadPhaseResumeUpload];
	}
}

- (void)retryOrProcessError:(NSError *)error
{    
    // Can retry chucnk session
    if (self.putUrl == nil && [self canRetryChunkSession])
    {
        [self retryChunkSession];
    }
    else
    {
		if (statusCode == 0)
		{
			statusCode = [error code];
		}
		
		if (retryCounter < 5)
		{
			[self retryUpload:NO];
			retryCounter++;
		}
		else
		{
			[self doPhase:ISUploadPhaseProcessError];
		}
    }    
}

- (NSString *)errorMessage
{
    switch (statusCode)
    {
        case 0: 
            return NSLocalizedString(@"Not Error", @"");
        case 404: 
            return NSLocalizedString(@"URL you are requesting is not found or command is not recognized", @"");
        case 405: 
            return NSLocalizedString(@"Method you are calling is not supported", @"");
        case 400: 
            return NSLocalizedString(@"Your request is bad formed, for example: missing or wrong UUID, invalid content-length.", @"");
        case 403: 
            return NSLocalizedString(@"Wrong developer key", @"");
        default:
            return NSLocalizedString(@"Unknown error", @"");
    }
}

- (NSData*)dataWithRange:(NSRange)range
{
    NSData *data = nil;
    if ([self fromFile])
    {
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:self.path];
        [file seekToFileOffset:range.location];
        data = [file readDataOfLength:range.length];
        [file closeFile];
    }
    else {
        data = [uploadData subdataWithRange:range];
    }
    return data;
}

- (unsigned long long)dataSize
{
    if (internalDataSize > 0)
        return internalDataSize;
    if ([self fromFile])
    {
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:self.path];
        if (file)
        {
            [file seekToEndOfFile];
            internalDataSize = [file offsetInFile];
            [file closeFile];
        }
    }
    else
    {
        internalDataSize = [uploadData length];
    }
    return internalDataSize;
}

- (BOOL)openConnection:(NSURLRequest*)request
{
#ifdef TRACE
	YFLog(@"YFrog_DEBUG: Executing openConnection method...");
	YFLog(@"	YFrog_DEBUG: Creating and running new connection with request %@", [request description]);
#endif	
	
    if (nil != connection)
	{
        return NO;
	}
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	isOpened = (nil != connection);
        
    [connection start];
    
    return isOpened;
}


- (void)closeConnection
{
    if (nil != connection)
    {
        [connection release];
        connection = nil;
    }
	
    isOpened = NO;
}

@end

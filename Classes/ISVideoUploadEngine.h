//
//  ISUploadEngine.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/30/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HTTPUploadTimeout   300

typedef enum {
    ISUploadPhaseNone,
    ISUploadPhaseStart,
    ISUploadPhaseUploadData,
    ISUploadPhaseResumeUpload,
    ISUploadPhaseProcessError,
    ISUploadPhaseFinish
} ISUploadEnginePhaseType;

@class  ISVideoUploadEngine;

@protocol ISVideoUploadEngineDelegate

- (void)didStartUploading:(ISVideoUploadEngine *)engine totalSize:(NSUInteger)size;
- (void)didFinishUploading:(ISVideoUploadEngine *)engine videoUrl:(NSString *)link;
- (void)didFailWithErrorMessage:(ISVideoUploadEngine *)engine errorMessage:(NSString *)error;
- (void)didFinishUploadingChunck:(ISVideoUploadEngine *)engine uploadedSize:(NSUInteger)totalUploadedSize totalSize:(NSUInteger)size;
- (void)didStopUploading:(ISVideoUploadEngine *)engine;
- (void)didResumeUploading:(ISVideoUploadEngine *)engine;

@end

@interface ISVideoUploadEngine : NSObject
{
@private
    NSURLConnection                 *connection;
    NSString                        *boundary;
    NSData                          *uploadData;
    NSString                        *username;
    NSString                        *password;
    NSString                        *verifyUrl;
    NSMutableData                   *result;
    NSString                        *linkUrl;
    NSString                        *putUrl;
    NSString                        *getLengthUrl;
    int                              statusCode;
    NSUInteger                       currentDataLocation;
    int                              phase;
    id<ISVideoUploadEngineDelegate>  delegate;
    NSString                        *path;
    unsigned long long               internalDataSize;
	
	NSInteger						sessionCount;
	NSInteger						retryCounter;
	BOOL							isOpened;
	NSTimer							*timer;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *verifyUrl;
@property (readonly)        NSData   *uploadData;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSString *putUrl;
@property (nonatomic, copy) NSString *getLengthUrl;
@property (nonatomic, retain) NSString *path;

@property (nonatomic, readonly) BOOL isOpened;

// Init upload ojbect
- (id)initWithData:(NSData *)theData delegate:(id<ISVideoUploadEngineDelegate>) dlgt;

- (id)initWithPath:(NSString*)path delegate:(id<ISVideoUploadEngineDelegate>) dlgt;
// Upload media data to server
- (BOOL)upload;

// Cancel uploading process
- (void)cancel;

- (BOOL)fromFile;

@end

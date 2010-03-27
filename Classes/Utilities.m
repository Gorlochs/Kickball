//
//  Utilities.m
//  Kickball
//
//  Created by Shawn Bernard on 12/10/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "Utilities.h"
#import "FoursquareAPI.h"
#import "FSUser.h"

const NSString *kKBHashSalt = @"33eBMKjsW9CTWpX4njEKarkWGoH9ZdzP";

static Utilities *sharedInstance = nil;

#define TMP NSHomeDirectory()

@implementation Utilities

@synthesize friendsWithPingOn, foursquareCheckinDateFormatter;

+ (Utilities*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil){
			sharedInstance = [[Utilities alloc] init];
		}
	}
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (NSDateFormatter*) foursquareCheckinDateFormatter {
    if (!foursquareCheckinDateFormatter) {
        foursquareCheckinDateFormatter = [[NSDateFormatter alloc] init];
        [foursquareCheckinDateFormatter setDateFormat:@"EEE, dd MMM yy HH:mm:ss"];
        [foursquareCheckinDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];  
    }
    return foursquareCheckinDateFormatter;
}

- (void) cacheImage: (NSString *) imageURLString {
    NSURL *imageURL = [NSURL URLWithString: imageURLString];
    
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [[imageURL path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *homeLibraryCache = [TMP stringByAppendingPathComponent:@"/Library/Caches"];
    NSString *uniquePath = [homeLibraryCache stringByAppendingPathComponent: filename];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
        
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: imageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        [data release];
        // Do we want to round the corners?
        //image = [self roundCorners: image];
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([imageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            NSLog(@"save png to filesystem: %@", filename);
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [imageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                [imageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            NSLog(@"save jpg to filesystem: %@", filename);
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
        [image release];
    }
}

- (UIImage *) getCachedImage: (NSString *) imageURLString
{
    UIImage *image = nil;
    if (imageURLString != nil) {
        NSURL *imageURL = [NSURL URLWithString: imageURLString];
        NSString *filename = [[imageURL path] stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSString *homeLibraryCache = [TMP stringByAppendingPathComponent:@"/Library/Caches"];
        NSString *uniquePath = [homeLibraryCache stringByAppendingPathComponent: filename];
        
        // Check for a cached version
        if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
        {
            NSLog(@"pulling image from cache: %@", filename);
            image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
        } else {
            // get a new one
            if ([imageURLString rangeOfString: @".gif" options: NSCaseInsensitiveSearch].location != NSNotFound) {
                // this sucks
                NSData *data = [[NSData alloc] initWithContentsOfURL: imageURL];
                image = [[[UIImage alloc] initWithData: data] autorelease];
                [data release];
            } else {
                [self cacheImage: imageURLString];
                image = [UIImage imageWithContentsOfFile: uniquePath];
            }
        }        
    }
    
    return image;
}

- (NSMutableArray*) friendsWithPingOn {
    if (friendsWithPingOn) {
        return friendsWithPingOn;
    } else {
        [self retrieveAllFriendsWithPingOn];
        return nil;
    }
}

- (void) retrieveAllFriendsWithPingOn {
    [[FoursquareAPI sharedInstance] getFriendsWithTarget:self andAction:@selector(friendsResponseReceived:withResponseString:)];
}

- (void)friendsResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    if (friendsWithPingOn == nil) {
        NSArray *allFriends = [[FoursquareAPI friendUsersFromRequestResponseXML:inString] retain];
        totalNumberOfUsersForPush = [allFriends count];
        NSLog(@"total number of friends: %d", totalNumberOfUsersForPush);
        friendsWithPingOn = [[NSMutableArray alloc] initWithCapacity:1];
        for (FSUser *friend in allFriends) {
            //NSLog(@"friend: %@", friend);
            [[FoursquareAPI sharedInstance] getUser:friend.userId withTarget:self andAction:@selector(aFriendResponseReceived:withResponseString:)];
            NSLog(@"running total: %d", runningTotalNumberOfUsersBeingPushed);
        }
        [allFriends release];
    }
}

- (void)aFriendResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    //NSLog(@"friend: %@", inString);
    FSUser *friend = [FoursquareAPI userFromResponseXML:inString];
    if (friend.sendsPingsToSignedInUser) {
        [friendsWithPingOn addObject:friend];
    }
    runningTotalNumberOfUsersBeingPushed++;
    if (runningTotalNumberOfUsersBeingPushed == totalNumberOfUsersForPush) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"friendsWithPingOnReceived" object: nil];
    }
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+(UIImage *)makeRoundCornerImage:(UIImage*)img cornerwidth:(int)cornerWidth cornerheight:(int)cornerHeight
{
	UIImage * newImage = nil;
    
	if( nil != img)
	{
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		int w = img.size.width;
		int h = img.size.height;
        
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
        
		CGContextBeginPath(context);
		CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
		addRoundedRectToPath(context, rect, cornerWidth, cornerHeight);
		CGContextClosePath(context);
		CGContextClip(context);
        
		CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
        
		CGImageRef imageMasked = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		//[img release];
        
		newImage = [[UIImage imageWithCGImage:imageMasked] retain];
		CGImageRelease(imageMasked);
        
		[pool release];
	}
    
    return newImage;
}


+ (NSDate*) convertUTCCheckinDateToLocal:(NSDate*)utcDate {
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSTimeInterval localTimeInterval = [utcDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:localTimeInterval];
    return localDate;
}

@end

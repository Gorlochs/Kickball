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
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "FSCheckin.h"
#import "GraphAPI.h"
#import "KBLocationManager.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

static Utilities *sharedInstance = nil;

#define TMP NSHomeDirectory()


@implementation Utilities

@synthesize friendsWithPingOn, foursquareCheckinDateFormatter, userIdsToReceivePings;

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

+ (natural_t)getMemory {
	mach_port_t host_port;
	mach_msg_type_number_t host_size;
	vm_size_t pagesize;
	host_port = mach_host_self();
	host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	host_page_size(host_port, &pagesize);
	vm_statistics_data_t vm_stat;
	if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
	NSLog(@"Failed to fetch vm statistics");
	return 0;
	}
	/* Stats in bytes */
	natural_t mem_free = vm_stat.free_count * pagesize;
	return mem_free;
}

+ (NSString*)safeString:(NSString*)fromString {
  if (fromString && [fromString isKindOfClass:[NSString class]]) return fromString;
  return [[[NSString alloc] initWithString:@""] autorelease];
}

//post to facebook with google maps image
+ (void)putGoogleMapsWallPostWithMessage:(NSString*)message andVenue:(FSVenue*)venue andLink:(NSString*)link {    
	NSDictionary *googleMapPic = nil;
    NSMutableString *urlPath = [[NSMutableString alloc] initWithString:@"http://maps.google.com/maps/api/staticmap?zoom=14&size=96x96&markers=icon:http://s3.amazonaws.com/kickball/assets/pin2.png|"];
    if (venue && venue.venueAddress) {
        NSMutableString *addy = [[NSMutableString alloc] initWithString:venue.venueAddress];
        [addy replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:NSMakeRange(0, [addy length])];
        [urlPath appendFormat:@"%@&sensor=true", addy];
        NSString *fullAddress = [NSString stringWithFormat:@"%@, %@, %@", venue.addressWithCrossstreet, venue.city, venue.venueState];
        googleMapPic = [[NSDictionary alloc] initWithObjectsAndKeys:venue.name, @"name", urlPath, @"picture",fullAddress,@"caption",@" ",@"description", [Utilities safeString:link], @"link", nil];
        [addy release];
    } else {
        double lat = [[KBLocationManager locationManager] latitude];
        double lng = [[KBLocationManager locationManager] longitude];
        [urlPath appendFormat:@"%f,%f&sensor=true", lat,lng];
        googleMapPic = [[NSDictionary alloc] initWithObjectsAndKeys:@" ", @"name", urlPath, @"picture",@"Kickball",@"caption",@" ",@"description", [Utilities safeString:link], @"link", nil];
    }
    [urlPath release];
    GraphAPI *graph = [[FacebookProxy instance] newGraph];
    [graph putWallPost:@"me" message:message attachment:googleMapPic];
    [graph release];
	[googleMapPic release];
}    

- (NSDateFormatter*) foursquareCheckinDateFormatter {
    if (!foursquareCheckinDateFormatter) {
        foursquareCheckinDateFormatter = [[NSDateFormatter alloc] init];
        [foursquareCheckinDateFormatter setDateFormat:@"EEE, dd MMM yy HH:mm:ss Z"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [foursquareCheckinDateFormatter setLocale:locale];
        [locale release];
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
            DLog(@"save png to filesystem: %@", filename);
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [imageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                [imageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            DLog(@"save jpg to filesystem: %@", filename);
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
            DLog(@"pulling image from cache: %@", filename);
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

#pragma mark -
#pragma mark Retrieve ping-on friends

- (void) updateAllFriendsWithPingOn:(NSArray*)checkins {
	pool = [[NSAutoreleasePool alloc] init];
	
	ids = [[NSMutableString alloc] initWithCapacity:1];
	
	for (FSCheckin *checkin in checkins) {
		if (checkin.checkedInUserGetsPings) {
			[ids appendFormat:@"%@%@", [ids length] < 1 ? @"" : @",", checkin.user.userId];
		}
	}
	
	DLog("ping ids: %@", ids);
	NSURL *url = [NSURL URLWithString:@"http://kickball.gorlochs.com/kickball/pings"];
	
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
	[request setPostValue:[[FoursquareAPI sharedInstance] currentUser].userId forKey:@"userId"];
	[request setPostValue:ids forKey:@"friendIds"];
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(pingSubmitCompleted:)];
	[request setDidFailSelector: @selector(pingSubmitFailed:)];
	[queue addOperation:request];
	[request release];
	[queue release];
	[ids release];
	[pool release];
}

- (void) pingSubmitFailed:(ASIHTTPRequest *) request {
    DLog(@"BOOOOOOOOOOOO!");
    DLog(@"response msg: %@", request.responseStatusMessage);
	//[pool release];
}

- (void) pingSubmitCompleted:(ASIHTTPRequest *) request {
    DLog(@"YAAAAAAAAAAAY!");
    DLog(@"response msg: %@", request.responseStatusMessage);
	//[pool release];
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

+ (NSDate*) convertUTCCheckinDateToLocal:(NSDate*)utcDate {
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSTimeInterval localTimeInterval = [utcDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:localTimeInterval];
    return localDate;
}

- (NSNumber*) getCityRadius {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *radius = [NSNumber numberWithInt:CITY_RADIUS_SMALL]; //25 miles is 40,233.6 meters
    if (userDefaults) {
        NSNumber *cityRadius = [NSNumber numberWithInteger:[userDefaults integerForKey:kCityRadiusKey]];
        if (cityRadius && cityRadius != [NSNumber numberWithInt:0]) {
            return cityRadius;
        } else {
            [userDefaults setValue:radius forKey:kCityRadiusKey];
            return radius;
        }
    }
	return radius;
}

- (void) setCityRadius:(int)meters {
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:meters] forKey:kCityRadiusKey];
}

+ (NSString*) getShortenedUrlFromFoursquareVenueId:(NSString*)venueId {
	return [Utilities shortenUrl:[Utilities convertVenueToFoursquareUrl:venueId]];
}

+ (NSString*) convertVenueToFoursquareUrl:(NSString*)venueId {
	return [NSString stringWithFormat:@"http://www.foursquare.com/venue/%@", venueId];
}

+ (NSString*) shortenUrl:(NSString*)longUrl {
	NSString *isGdString = [NSString stringWithFormat:@"http://is.gd/api.php?longurl=%@", longUrl];
	NSURL *isGdUrl = [NSURL URLWithString:isGdString];
	NSString *shortenedUrlString = [NSString stringWithContentsOfURL:isGdUrl encoding:NSASCIIStringEncoding error:nil];
	return shortenedUrlString;
}



@end

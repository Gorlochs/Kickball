//
//  KickballAPI.m
//  Kickball
//
//  Created by Shawn Bernard on 3/31/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KickballAPI.h"
#import "ASIHTTPRequest.h"
#import "Utilities.h"
#import "KBGoody.h"
#import "TouchXML.h"
#import "MGTwitterXMLParser.h"


static KickballAPI* _kickballApi = nil;

@implementation KickballAPI

@synthesize photoDateFormatter;
@synthesize twitterDateFormatter;
@synthesize twitterSearchDateFormatter;
@synthesize goodyDateFormatter;

- (NSMutableArray*) parsePhotosFromXML:(NSString*)responseString {
    
    NSMutableArray *goodies = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];

    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithXMLString:responseString options:0 error:nil] autorelease];

    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;

    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//gift" error:nil];

    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
        
        KBGoody *goody = [[KBGoody alloc] init];
        
        // Loop through the children of the current  node
        for (int counter = 0; counter < [resultElement childCount]; counter++) {
            
            // TODO: we can also just pass in the resultElement into a KBGoody constructor and let the object take care of the object construction
            
            NSString *name = [[resultElement childAtIndex:counter] name];
            NSString *value = [[resultElement childAtIndex:counter] stringValue];
            if ([name isEqualToString:@"is-banned"]) {
                goody.isBanned = [value boolValue];
            } else if ([name isEqualToString:@"is-public"]) {
                goody.isPublic = [value boolValue];
            } else if ([name isEqualToString:@"message-text"]) {
                goody.messageText = value;
            } else if ([name isEqualToString:@"name"]) {
                
            } else if ([name isEqualToString:@"owner-id"]) {
                goody.ownerId = value;
            } else if ([name isEqualToString:@"photo-file-name"]) {
                goody.imageName = value;
            } else if ([name isEqualToString:@"recipient-id"]) {
                goody.recipientId = value;
            } else if ([name isEqualToString:@"uuid"]) {
                goody.goodyId = value;
            } else if ([name isEqualToString:@"venue-id"]) {
                goody.venueId = value;
            } else if ([name isEqualToString:@"venue-name"]) {
                goody.venueName = value;
            } else if ([name isEqualToString:@"owner-name"]) {
                goody.ownerName = value;
            } else if ([name isEqualToString:@"photo-height"]) {
                goody.imageHeight = [value intValue];
            } else if ([name isEqualToString:@"photo-width"]) {
                goody.imageWidth = [value intValue];
            } else if ([name isEqualToString:@"created-at"]) {
                goody.createdAt = [Utilities convertUTCCheckinDateToLocal:[goodyDateFormatter dateFromString:[[value stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@""]]];
            }
        }
        
        [goodies addObject:goody];
        [goody release];
    }
    
    return goodies;
}

#pragma mark singleton stuff

+ (KickballAPI*) kickballApi {
	@synchronized([KickballAPI class])
	{
		if (!_kickballApi)
			[[self alloc] init];
        
		return _kickballApi;
	}
    
	return nil;
}

- (MockPhotoSource*) convertGoodiesIntoPhotoSource:(NSArray*)goodies withTitle:(NSString*)photoSourceTitle {
    NSMutableArray *tempTTPhotoArray = [[[NSMutableArray alloc] initWithCapacity:[goodies count]] autorelease];
    for (KBGoody *goody in goodies) {
        NSString *caption = nil;
        if (goody.messageText != nil && ![goody.messageText isEqualToString:@"testing"]) {
            caption = [NSString stringWithFormat:@"%@ \n %@ @ %@ on %@", goody.messageText, goody.ownerName, goody.venueName, [photoDateFormatter stringFromDate:goody.createdAt]];
        } else {
            caption = [NSString stringWithFormat:@"%@ @ %@ on %@", goody.ownerName, goody.venueName, [photoDateFormatter stringFromDate:goody.createdAt]];
        }
        
        MockPhoto *photo = [[MockPhoto alloc] initWithURL:goody.largeImagePath smallURL:goody.mediumImagePath size:[goody largeImageSize] caption:caption];
        [tempTTPhotoArray addObject:photo];
        [photo release];
    }
    
    return [[[MockPhotoSource alloc] initWithType:MockPhotoSourceNormal title:photoSourceTitle photos:tempTTPhotoArray photos2:nil] autorelease];
}

- (NSString*) convertDateToTimeUnitString:(NSDate*)dateToConvert {
    NSString *convertedDateString = @"";
//    NSDate *oneHourFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*1];
//    NSDate *twentyfourHoursFromNow = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24];
    
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:dateToConvert options:0];
    [gregorian release];
    NSInteger minutes = [components minute] * -1;
    NSInteger hours = [components hour] * -1;
    NSInteger days = [components day] * -1;
    
    if (days == 0 && hours == 0) {
        convertedDateString = [NSString stringWithFormat:@"%d minute%@ ago", minutes, minutes > 1 ? @"s" : @""];
    } else if (days == 0) {
        convertedDateString = [NSString stringWithFormat:@"%d hour%@ ago", hours, hours > 1 ? @"s" : @""];
    } else {
        convertedDateString = [NSString stringWithFormat:@"%d day%@ ago", days, days > 1 ? @"s" : @""];
    }
    
    return convertedDateString;
}

- (NSDate*) convertToUTC:(NSDate*)sourceDate {
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone* utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset - currentGMTOffset;
    
    NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:sourceDate] autorelease];     
    return destinationDate;
}

#pragma mark singleton methods


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_kickballApi == nil) {
            _kickballApi = [super allocWithZone:zone];
            return _kickballApi;  // assignment and return on first allocation
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
  DLog(@"kickball api released");
    //do nothing
}
- (void)dealloc {
  DLog(@"kickball api dealloc - leaking memory");
  [super dealloc];
}

- (id)autorelease {
    return self;
}

+ (id) alloc {
	@synchronized([KickballAPI class])
	{
		NSAssert(_kickballApi == nil, @"Attempted to allocate a second instance of a singleton.");
		_kickballApi = [super alloc];
		return _kickballApi;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        // prepare date formatter
        goodyDateFormatter = [[NSDateFormatter alloc] init];
        [goodyDateFormatter setLocale:locale];
        [goodyDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        // prepare other date formatter
        photoDateFormatter = [[NSDateFormatter alloc] init];
        [photoDateFormatter setLocale:locale];
        [photoDateFormatter setDateFormat:@"LLLL dd, hh:mm a"];
        
        // prepare twitter date formatter
        twitterDateFormatter = [[NSDateFormatter alloc] init];
        [twitterDateFormatter setLocale:locale];
        [twitterDateFormatter setDateFormat:kMGTwitterDateFormatString];

        twitterSearchDateFormatter = [[NSDateFormatter alloc] init];
        [twitterSearchDateFormatter setLocale:locale];
        [twitterSearchDateFormatter setDateFormat:kMGTwitterSearchDateFormatString];
        
        [locale release];
	}
    
	return self;
}

@end

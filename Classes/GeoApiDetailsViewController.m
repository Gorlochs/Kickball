//
//  GeoApiDetailsViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 11/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import "GeoApiDetailsViewController.h"
#import "GAConnectionManager.h"
#import "SBJSON.h"
#import "ASIHTTPRequest.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation GeoApiDetailsViewController

@synthesize place;


- (void)viewDidLoad {
    hideFooter = YES;
    pageType = KBPageTypeOther;
    pageViewType = KBPageViewTypeList;
    
    [super viewDidLoad];
    
    features.font = [UIFont systemFontOfSize:12.0];
    tags.font = [UIFont systemFontOfSize:12.0];
    hours.font = [UIFont systemFontOfSize:12.0];
    features.textColor = [UIColor whiteColor];
    tags.textColor = [UIColor whiteColor];
    hours.textColor = [UIColor whiteColor];
    features.text = @"";
    tags.text = @"";
    hours.text = @"";
    venueName.text = @"";
    venueAddress.text = @"";

    [self startProgressBar:@"Retrieving venue details..."];
    connectionManager_ = [[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self];
    [connectionManager_ requestListingForPlace:place.guid];
    
//    // http://api2.citysearch.com/profile/?listing_id=273&publisher=gorlochs&client_ip=122.123.124.125&api_key=cpm3fbn4wf4ymf9hvjwuv47u
//    NSString *cityGridUrl = [NSString stringWithFormat:@"http://api2.citysearch.com/profile/?client_ip=%@&listing_id=%@&format=json&&publisher=gorlochs&api_key=cpm3fbn4wf4ymf9hvjwuv47u",
//                             [self getIPAddress],
//                             place.guid];
//    DLog(@"city grid search url: %@", cityGridUrl);    
//    ASIHTTPRequest *cityGridRequest = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:cityGridUrl]] autorelease];
//    
//    [cityGridRequest setDidFailSelector:@selector(cityGridRequestWentWrong:)];
//    [cityGridRequest setDidFinishSelector:@selector(cityGridRequestDidFinish:)];
//    [cityGridRequest setTimeOutSeconds:500];
//    [cityGridRequest setDelegate:self];
//    [cityGridRequest startAsynchronous];
}

#pragma mark CityGrid methods

- (void) cityGridRequestWentWrong:(ASIHTTPRequest *) request {
    DLog(@"BOOOOOOOOOOOO!");
}

- (void) cityGridRequestDidFinish:(ASIHTTPRequest *) request {
    SBJSON *parser = [SBJSON new];
    id dict = [parser objectWithString:[request responseString] error:NULL];
	[parser release];
    NSArray *array = (NSArray*)[dict objectForKey:@"locations"];
    DLog(@"location: %@", [array objectAtIndex:0]);
    NSDictionary *locationDictionary = [array objectAtIndex:0];

    [self stopProgressBar];
    
    place.name = [locationDictionary objectForKey:@"name"];
    place.address = [[locationDictionary objectForKey:@"address"] objectForKey:@"street"];
    
    if (![[[locationDictionary objectForKey:@"reviews"] objectForKey:@"overall_review_rating"] isKindOfClass:[NSNull class]]) {
        int rating = [[[locationDictionary objectForKey:@"reviews"] objectForKey:@"overall_review_rating"] doubleValue] * 2;
        webRating.image = [UIImage imageNamed:[NSString stringWithFormat:@"rating-%d.png", rating]];
    } else {
        webRating.image = [UIImage imageNamed:@"webrating-na.png"];
    }
    
    venueName.text = place.name;
    venueAddress.text = [[locationDictionary objectForKey:@"address"] objectForKey:@"street"];
    if (![[locationDictionary objectForKey:@"features"] isKindOfClass:[NSNull class]]) {
        features.text = [[locationDictionary objectForKey:@"features"] componentsJoinedByString:@"\n\n"];
    } else {
        features.text = @"Features not available";
    }
    if (![[locationDictionary objectForKey:@"business_hours"] isKindOfClass:[NSNull class]]) {
        NSMutableString *finalHours = [NSMutableString stringWithCapacity:1];
        for (NSArray *array in [locationDictionary objectForKey:@"business_hours"]) {
            [finalHours appendString:[array componentsJoinedByString:@"\n"]];
            [finalHours appendString:@"\n"];
            //            [finalHours appendString:[array componentsJoinedByString:@": "]];
            //            [finalHours deleteCharactersInRange:NSMakeRange([finalHours length] - 2, 2)];
            //            [finalHours appendString:@"\n\n"];
        }
        hours.text = finalHours;
    } else {
        hours.text = @"Hours not available";
    }
//    if (![[results objectForKey:@"sips"] isKindOfClass:[NSNull class]]) {
//        tags.text = [[results objectForKey:@"sips"] componentsJoinedByString:@", "];
//    } else {
        tags.text = @"Tags not available";
//    }
    
    if ([[[locationDictionary objectForKey:@"urls"] objectForKey:@"website_url"] isKindOfClass:[NSNull class]]) {
        websiteButton.enabled = NO;
    }
}

- (void)receivedResponseString:(NSString *)responseString {
    DLog(@"geoapi response string: %@", responseString);
    
    //label.text = responseString;
    SBJSON *parser = [SBJSON new];
    id dict = [parser objectWithString:responseString error:NULL];
    NSDictionary *results = [(NSDictionary*)dict objectForKey:@"result"];
    
    place.listing = [[NSDictionary alloc] initWithDictionary:results];
    DLog(@"place listing: %@", place.listing);
    place.name = [results objectForKey:@"name"];
    place.address = [results objectForKey:@"address"];
    if (![[results objectForKey:@"web-wide-rating"] isKindOfClass:[NSNull class]]) {
        int rating = [[results objectForKey:@"web-wide-rating"] doubleValue] * 2;
        webRating.image = [UIImage imageNamed:[NSString stringWithFormat:@"rating-%d.png", rating]];
    } else {
        webRating.image = [UIImage imageNamed:@"webrating-na.png"];
    }
    
    venueName.text = place.name;
    venueAddress.text = [[results objectForKey:@"address"] componentsJoinedByString:@", "];
    if (![[results objectForKey:@"features"] isKindOfClass:[NSNull class]]) {
        features.text = [[results objectForKey:@"features"] componentsJoinedByString:@"\n\n"];
    } else {
        features.text = @"Features not available";
    }
    if (![[results objectForKey:@"hours"] isKindOfClass:[NSNull class]]) {
        NSMutableString *finalHours = [NSMutableString stringWithCapacity:1];
        for (NSArray *array in [results objectForKey:@"hours"]) {
            [finalHours appendString:[array componentsJoinedByString:@"\n"]];
            [finalHours appendString:@"\n"];
//            [finalHours appendString:[array componentsJoinedByString:@": "]];
//            [finalHours deleteCharactersInRange:NSMakeRange([finalHours length] - 2, 2)];
//            [finalHours appendString:@"\n\n"];
        }
        hours.text = finalHours;
    } else {
        hours.text = @"Hours not available";
    }
    if (![[results objectForKey:@"sips"] isKindOfClass:[NSNull class]]) {
        tags.text = [[results objectForKey:@"sips"] componentsJoinedByString:@", "];
    } else {
        tags.text = @"Tags not available";
    }
    
    if ([[place.listing objectForKey:@"listing-url"] isKindOfClass:[NSNull class]]) {
        websiteButton.enabled = NO;
    }
    [parser release];
    [self stopProgressBar];
}

- (void)requestFailed:(NSError *)error {
    DLog(@"geoapi error string: %@", error);
    [self stopProgressBar];
}

- (void) callVenue {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [results objectForKey:@"phone"]]]];
}

- (void) visitWebsite {
    DLog(@"site to visit: %@", [place.listing objectForKey:@"listing-url"]);
    [self openWebView:[place.listing objectForKey:@"listing-url"]];
}

- (NSString *)getIPAddress {
    NSString *address = @"123.123.123.123";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (void)dealloc {
	[connectionManager_ release];
    [place release];
    [venueName release];
    [venueAddress release];
    [webRating release];
    [hours release];
    [features release];
    [tags release];
    [websiteButton release];
    [super dealloc];
}

@end


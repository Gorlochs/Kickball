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

@implementation GeoApiDetailsViewController

@synthesize place;


- (void)viewDidLoad {
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

    GAConnectionManager *connectionManager_ = [[GAConnectionManager alloc] initWithAPIKey:@"K6afuuFTXK" delegate:self];
    [connectionManager_ requestListingForPlace:place.guid];
}

- (void)receivedResponseString:(NSString *)responseString {
    NSLog(@"geoapi response string: %@", responseString);
    
    //label.text = responseString;
    SBJSON *parser = [SBJSON new];
    id dict = [parser objectWithString:responseString error:NULL];
    NSDictionary *results = [(NSDictionary*)dict objectForKey:@"result"];
    
    place.listing = [[NSDictionary alloc] initWithDictionary:results];
    NSLog(@"place listing: %@", place.listing);
    place.name = [results objectForKey:@"name"];
    place.address = [results objectForKey:@"address"];
    if ([results objectForKey:@"web-wide-rating"] == nil) {
        int rating = [[results objectForKey:@"web-wide-rating"] doubleValue] * 2;
        webRating.image = [UIImage imageNamed:[NSString stringWithFormat:@"rating-%d.png", rating]];
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
}

- (void)requestFailed:(NSError *)error {
    NSLog(@"geoapi error string: %@", error);
}

- (void) callVenue {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [results objectForKey:@"phone"]]]];
}

- (void) visitWebsite {
    NSLog(@"site to visit: %@", [place.listing objectForKey:@"listing-url"]);
    [self openWebView:[place.listing objectForKey:@"listing-url"]];
}

- (void)dealloc {
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


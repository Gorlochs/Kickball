//
//  GeoApiDetailsViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/20/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFoursquareViewController.h"
#import "GAConnectionDelegate.h"
#import "GAPlace.h"


@interface GeoApiDetailsViewController : KBFoursquareViewController <GAConnectionDelegate, UITextFieldDelegate> {
    GAPlace *place;
    
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
    IBOutlet UIImageView *webRating;
    IBOutlet UITextView *hours;
    IBOutlet UITextView *features;
    IBOutlet UITextView *tags;
    IBOutlet UIButton *websiteButton;
}

@property (nonatomic, retain) GAPlace *place;

- (IBAction) callVenue;
- (IBAction) visitWebsite;

@end

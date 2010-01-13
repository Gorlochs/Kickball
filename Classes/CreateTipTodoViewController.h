//
//  CreateTipTodoViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/24/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "FSVenue.h"


@interface CreateTipTodoViewController : KBBaseViewController <UITextViewDelegate> {
    IBOutlet UISegmentedControl *tipTodoSwitch;
    IBOutlet UITextView *tipTodoText;
    NSString *tipId;
    FSVenue *venue;
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
}

@property (nonatomic, retain) FSVenue *venue;

- (void)tipTodoResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (IBAction) submitTipOrTodoToFoursquare;
- (IBAction) callVenue;
- (IBAction) cancel;

@end

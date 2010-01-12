//
//  CreateTipTodoViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 12/24/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface CreateTipTodoViewController : KBBaseViewController <UITextViewDelegate> {
    IBOutlet UISegmentedControl *tipTodoSwitch;
    IBOutlet UITextView *tipTodoText;
    NSString *tipId;
    NSString *venueId;
}

@property (nonatomic, retain) NSString *venueId;

- (void)tipTodoResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
- (IBAction) submitTipOrTodoToFoursquare;

@end

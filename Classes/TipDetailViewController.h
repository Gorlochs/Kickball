//
//  TipDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTip.h"
#import "FSVenue.h"
#import "KBBaseViewController.h"

@interface TipDetailViewController : KBBaseViewController {
    FSTip *tip;
    FSVenue *venue;
    
    IBOutlet UILabel *authorNameLabel;
    IBOutlet UILabel *tipText;
    IBOutlet UILabel *venueName;
    IBOutlet UILabel *venueAddress;
}

@property (nonatomic, retain) FSTip *tip;
@property (nonatomic, retain) FSVenue *venue;

- (IBAction) markTipAsTodoForUser;
- (IBAction) markTipAsDoneForUser;
- (IBAction) removeView;

@end

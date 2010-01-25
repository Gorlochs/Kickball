//
//  KBTextViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"

@interface KBTextViewController : KBBaseViewController <UITextViewDelegate> {
    IBOutlet UITextView *theTextView;
}

- (IBAction) shout;
- (IBAction) cancelView;

@end

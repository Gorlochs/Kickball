//
//  KBTextViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KBBaseViewController;

@interface KBTextViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView *textView;
}

- (IBAction) shout;
- (IBAction) cancelView;

@end

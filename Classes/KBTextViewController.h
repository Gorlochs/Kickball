//
//  KBTextViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 1/7/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBTextViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView *textView;
}

- (IBAction) cancelView;

@end

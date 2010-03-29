//
//  PhotoMessageViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/29/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface PhotoMessageViewController : KBBaseViewController {
    IBOutlet UITextView *photoMessage;
}

- (IBAction) addMessageToPhoto;
- (IBAction) noMessageThanks;

@end

//
//  KBPhotoViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/3/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupMessageView.h"
#import "KBBaseViewController.h"
#import "KBGenericPhotoViewController.h"

@interface KBPhotoViewController : KBGenericPhotoViewController <UIActionSheetDelegate> {
    NSInteger startIndex;
    
    UIBarButtonItem* _flagButton;
    
    NSArray *goodies;
    PopupMessageView *popupView;
}

@property (nonatomic) NSInteger startIndex;
@property (nonatomic, retain) NSArray *goodies;

- (void) displayPopupMessage:(KBMessage*)message;

@end

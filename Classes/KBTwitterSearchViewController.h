//
//  KBTwitterSearchViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/19/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseTweetViewController.h"


@interface KBTwitterSearchViewController : KBBaseTweetViewController <UITextFieldDelegate> {
    NSString *searchTerms;
    IBOutlet UITextField *theSearchBar;
	NSArray *localTwitterArray;
}

@property (nonatomic, assign) NSString *searchTerms;

@end

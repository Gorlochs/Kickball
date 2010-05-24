//
//  AddPlaceCategoryViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface AddPlaceCategoryViewController : KBBaseViewController {
    NSArray *categories;
}

- (IBAction) backToAddAVenue;

@end

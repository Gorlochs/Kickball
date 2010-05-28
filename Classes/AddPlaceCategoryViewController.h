//
//  AddPlaceCategoryViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/24/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "FSVenue.h"


@interface AddPlaceCategoryViewController : KBBaseViewController {
    NSArray *categories;
    FSVenue *newVenue;
}

@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) FSVenue *newVenue;

- (IBAction) backToAddAVenue;

@end

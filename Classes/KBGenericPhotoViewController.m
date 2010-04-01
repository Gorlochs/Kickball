//
//  KBGenericPhotoViewController.m
//  Kickball
//
//  Created by Shawn Bernard on 3/31/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import "KBGenericPhotoViewController.h"


@implementation KBGenericPhotoViewController

- (void)loadView {
    [super loadView];
    self.defaultImage = [UIImage imageNamed:@"imgLoader.png"];
    self.navigationController.navigationBarHidden = NO;
}

@end

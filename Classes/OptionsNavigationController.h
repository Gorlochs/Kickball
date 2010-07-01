//
//  OptionsNavigationController.h
//  Kickball
//
//  Created by scott bates on 7/1/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OptionsVC;
@interface OptionsNavigationController : UINavigationController {
	OptionsVC *account;
	OptionsVC *checkin;
	OptionsVC *friendPriority;
	OptionsVC *versionInfo;
	OptionsVC *feedback;
	OptionsVC *base;
}

@property(nonatomic, retain) OptionsVC *base;
@property(nonatomic, retain) OptionsVC *account;
@property(nonatomic, retain) OptionsVC *checkin;
@property(nonatomic, retain) OptionsVC *friendPriority;
@property(nonatomic, retain) OptionsVC *versionInfo;
@property(nonatomic, retain) OptionsVC *feedback;
@end

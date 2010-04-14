//
//  AbstractFacebookViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/6/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"
#import "KBFoursquareViewController.h"


@interface AbstractFacebookViewController : KBFoursquareViewController <FBDialogDelegate, FBSessionDelegate, FBRequestDelegate>  {
    FBSession* _session;
}

@end

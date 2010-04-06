//
//  KBFacebookSearchViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"
#import "FBConnect/FBConnect.h"


@interface KBFacebookSearchViewController : KBBaseViewController <FBDialogDelegate, FBSessionDelegate, FBRequestDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    FBSession* _session;
}

@end

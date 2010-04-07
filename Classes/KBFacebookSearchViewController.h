//
//  KBFacebookSearchViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 4/5/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractFacebookViewController.h"


@interface KBFacebookSearchViewController : AbstractFacebookViewController <UITableViewDelegate, UITableViewDataSource> {

}

- (IBAction) askPermissionPublishStream;

@end

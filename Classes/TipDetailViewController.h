//
//  TipDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 11/29/09.
//  Copyright 2009 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTip.h"
#import "KBBaseViewController.h"

@interface TipDetailViewController : KBBaseViewController <UITableViewDelegate, UITableViewDataSource> {
    FSTip *tip;
    
    IBOutlet UILabel *authorNamelabel;
    IBOutlet UIButton *authorIcon;
    IBOutlet UILabel *createdOnLabel;
    IBOutlet UITextView *tipText;
}

@property (nonatomic, retain) FSTip *tip;

@end

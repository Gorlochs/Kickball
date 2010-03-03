//
//  PhotoDetailViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 3/2/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBAsyncImageView.h"

@interface PhotoDetailViewController : UIViewController {
    NSArray *goodyList;
    NSInteger photoIndexToDisplay;
    IBOutlet KBAsyncImageView *photo;
    IBOutlet UILabel *photoLabel;
}

@property (nonatomic, retain) NSArray *goodyList;
@property (nonatomic) NSInteger photoIndexToDisplay;

@end

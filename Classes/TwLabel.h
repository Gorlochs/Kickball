//
//  TwLabel.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 1/5/10.
//  Copyright 2010 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwLabel : UILabel {
@private
    NSString    *_mask;
}

@property (nonatomic, retain) NSString *mask;
@end

//
//  KBInstacheckinTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 4/1/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBInstacheckinTableCell : UITableViewCell {
    BOOL _cancelTouches;
    NSString *venueId;
}

@property (nonatomic) BOOL _cancelTouches;
@property (nonatomic, retain) NSString *venueId;

@end

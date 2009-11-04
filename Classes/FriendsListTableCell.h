//
//  FriendsListTableCell.h
//  Kickball
//
//  Created by Shawn Bernard on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendsListTableCell : UITableViewCell {
	IBOutlet UIImageView * profileIcon;
	IBOutlet UILabel * checkinDisplayLabel;
	IBOutlet UILabel * addressLabel;
}

@property (nonatomic, retain) UIImageView * profileIcon;
@property (nonatomic, retain) UILabel * checkinDisplayLabel;
@property (nonatomic, retain) UILabel * addressLabel;

@end

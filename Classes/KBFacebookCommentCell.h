//
//  KBFacebookCommentCell.h
//  Kickball
//
//  Created by scott bates on 6/18/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"


@interface KBFacebookCommentCell : UITableViewCell {
	TTImageView *userIcon;
	UIImageView *iconBgImage;
    TTStyledTextLabel *commentText;
	NSString *fbPictureUrl;
	UIImageView *topLineImage;
    UIImageView *bottomLineImage;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) TTStyledTextLabel *commentText;
@property (nonatomic, retain) NSString *fbPictureUrl;

@end

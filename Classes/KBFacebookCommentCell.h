//
//  KBFacebookCommentCell.h
//  Kickball
//
//  Created by scott bates on 6/18/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "CoreTableCellWithProfilePic.h"


@interface KBFacebookCommentCell : CoreTableCellWithProfilePic {
    TTStyledTextLabel *commentText;
	NSString *fbPictureUrl;
}
@property (nonatomic, retain) TTStyledTextLabel *commentText;
@property (nonatomic, retain) NSString *fbPictureUrl;

@end

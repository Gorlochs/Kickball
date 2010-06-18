//
//  KBFacebookPostDetail.h
//  Kickball
//
//  Created by scott bates on 6/14/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"
#import "Three20/Three20.h"


@class GraphObject;
@interface KBFacebookPostDetailViewController : KBFacebookViewController {
	GraphObject *fbItem;
	IBOutlet UIView *postView;
	IBOutlet UIView *commentView;
	
	TTImageView *userIcon;
	UIImageView *iconBgImage;
    TTStyledTextLabel *fbPostText;
	TTStyledTextLabel *commentHightTester;
	UILabel *dateLabel;
	int numComments;
	NSString *fbPictureUrl;
	
	NSArray *comments;
}
@property(nonatomic,retain)UIView *postView;
@property(nonatomic,retain)UIView *commentView;

-(void)populate:(GraphObject*)obj;
-(IBAction)pressLike;
-(IBAction)touchComment;
@end

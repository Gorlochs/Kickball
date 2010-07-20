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


@interface KBFacebookPostDetailViewController : KBFacebookViewController {
	NSDictionary *fbItem;
	IBOutlet UIView *postView;
	IBOutlet UIView *commentView;
	
	TTImageView *userIcon;
	UIImageView *iconBgImage;
    TTStyledTextLabel *fbPostText;
	TTStyledTextLabel *commentHightTester;
	UILabel *dateLabel;
	int numComments;
	NSString *fbPictureUrl;
	TTImageView *pictureThumb1;
	UIButton *pictureButt;
	NSString *pictureAlbumId;
	
	NSArray *comments;
	NSString *nextPageURL;
	BOOL requeryWhenTableGetsToBottom;
}
@property(nonatomic,retain)UIView *postView;
@property(nonatomic,retain)UIView *commentView;

-(void)populate:(NSDictionary*)obj;
-(IBAction)pressLike;
-(void)pressLikeThreaded;
-(IBAction)touchComment;
-(void)concatenateMore:(NSString*)urlString;
-(void)pressPhotoAlbum;
@end

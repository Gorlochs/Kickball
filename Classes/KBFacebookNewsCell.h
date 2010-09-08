//
//  KBFacebookNewsCell.h
//  Kickball
//
//  Created by scott bates on 6/11/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "Utilities.h"
#import "CoreTableCellWithProfilePic.h"

@interface KBFacebookNewsCell : CoreTableCellWithProfilePic {
	
    TTStyledTextLabel *tweetText;
	UILabel *dateLabel;
	int comments;
	NSString *fbProfilePicUrl;
	NSString *fbPictureUrl;
	
    UILabel *userName;

   	UIImageView *commentBG;
	UILabel *commentNumber;
	TTImageView *pictureThumb1;
	UIButton *pictureButt;
	NSString *pictureAlbumId;
	NSNumber *pictureIndex;
}

@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) TTStyledTextLabel *tweetText;
@property (nonatomic, retain) NSString *fbProfilePicUrl;
@property (nonatomic, retain) NSString *fbPictureUrl;
@property (nonatomic, retain) NSString *pictureAlbumId;
@property (nonatomic, retain) NSNumber *pictureIndex;


- (void) setDateLabelWithDate:(NSDate*)theDate;
- (void) setDateLabelWithText:(NSString*)theDate;
- (void) pushToProfile;
-(void)setNumberOfComments:(int)howMany;
-(void)pressPhotoAlbum;
@end

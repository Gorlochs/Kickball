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

@interface KBFacebookNewsCell : UITableViewCell {
	TTImageView *userIcon;
	UIImageView *iconBgImage;
    TTStyledTextLabel *tweetText;
	UILabel *dateLabel;
	int comments;
	NSString *fbProfilePicUrl;
	NSString *fbPictureUrl;
	
    UILabel *userName;

    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
	UIButton *iconButt;
	UIImageView *commentBG;
	UILabel *commentNumber;
	TTImageView *pictureThumb1;
	UIActivityIndicatorView *pictureActivityIndicator;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) TTStyledTextLabel *tweetText;
@property (nonatomic, retain) NSString *fbProfilePicUrl;
@property (nonatomic, retain) NSString *fbPictureUrl;


- (void) setDateLabelWithDate:(NSDate*)theDate;
- (void) setDateLabelWithText:(NSString*)theDate;
- (void) pushToProfile;
-(void)setNumberOfComments:(int)howMany;
@end

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

@class GraphAPI;
@interface KBFacebookNewsCell : UITableViewCell {
	TTImageView *userIcon;
    
    UILabel *userName;
    TTStyledTextLabel *tweetText;
    UILabel *dateLabel;
    
    UIImageView *topLineImage;
    UIImageView *bottomLineImage;
    UIImageView *iconBgImage;
	UIButton *iconButt;
	NSString *fbPictureUrl;
	GraphAPI *fbGraph;
}

@property (nonatomic, retain) TTImageView *userIcon;
@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) TTStyledTextLabel *tweetText;
@property (nonatomic, retain) NSString *fbPictureUrl;

- (void) setDateLabelWithDate:(NSDate*)theDate;
- (void) setDateLabelWithText:(NSString*)theDate;
- (void) pushToProfile;
@end

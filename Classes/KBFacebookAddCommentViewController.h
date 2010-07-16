//
//  KBFacebookAddCommentViewController.h
//  Kickball
//
//  Created by scott bates on 6/18/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBBaseViewController.h"


@interface KBFacebookAddCommentViewController : KBBaseViewController <UITextViewDelegate>  {
	IBOutlet UITextView *tipTodoText;
    NSString *tipId;
	NSString *fbId;
    IBOutlet UILabel *characterCount;
	id parentView;
	BOOL isComment;
}
@property(nonatomic,retain)NSString *fbId;
@property(nonatomic,retain)id parentView;
@property(nonatomic,assign)BOOL isComment;

//- (void)tipTodoResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString;
//- (IBAction) submitTipOrTodoToFoursquare;
- (IBAction) cancel;


@end

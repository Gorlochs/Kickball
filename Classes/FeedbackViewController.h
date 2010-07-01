//
//  FeedbackViewController.h
//  Kickball
//
//  Created by Shawn Bernard on 5/23/10.
//  Copyright 2010 Gorloch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsVC.h"


@interface FeedbackViewController : OptionsVC <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate>{
	IBOutlet UIPickerView *subjectPicker;
	NSMutableArray *subjects;
	IBOutlet UILabel *subjectLabel;
	IBOutlet UIButton *subjectButt;
	IBOutlet UITextView *content;
}

- (IBAction) nextOptionView;
- (IBAction) showPicker;
- (void) hidePicker;
-(void)sendFeedback;

@end

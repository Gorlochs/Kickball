//
//  KBFoursquareLoginView.h
//  Kickball
//
//  Created by scott bates on 6/22/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface KBFoursquareLoginView : UIView <UITextFieldDelegate>{
	IBOutlet UIView *hideKeyboardView;
	IBOutlet UITextField *userName;
	IBOutlet UITextField *password;
	id delegate;

}
@property(nonatomic,retain)id delegate;
-(IBAction)hideKeyboard;
@end

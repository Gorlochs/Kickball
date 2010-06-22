//
//  KBFoursquareLoginView.m
//  Kickball
//
//  Created by scott bates on 6/22/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import "KBFoursquareLoginView.h"
#import "FoursquareAPI.h"
#import "KBMessage.h"
#import "FlurryAPI.h"
#import "KBBaseViewController.h"
#import "KickballAppDelegate.h"
#import "SFHFKeychainUtils.h"


@implementation KBFoursquareLoginView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(IBAction)hideKeyboard{
	[userName resignFirstResponder];
	[password resignFirstResponder];
}

#pragma mark -
#pragma mark Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	[hideKeyboardView setCenter:CGPointMake(160, 180)];    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //DLog(@"text field did end editing: %@", textField);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
	[hideKeyboardView setCenter:CGPointMake(160, 400)];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField==userName) {
		[userName resignFirstResponder];
		[password becomeFirstResponder];
	}else {
		[password resignFirstResponder];
		[delegate startProgressBar:@"Logging in..."];
		[[FoursquareAPI sharedInstance] getFriendsWithTarget:userName.text andPassword:password.text andTarget:self andAction:@selector(friendResponseReceived:withResponseString:)];

	}

    //[self cancelEditing];
    return NO;
}

- (void)friendResponseReceived:(NSURL *)inURL withResponseString:(NSString *)inString {
    DLog(@"friend response for login: %@", inString);
    [delegate stopProgressBar];
    // cheap way of checking for successful authentication
    BOOL containsUnauthorized = [inString rangeOfString:@"unauthorized" options:NSCaseInsensitiveSearch].length > 0;
    if (containsUnauthorized) {
        // display fail message
		//[password becomeFirstResponder];
        KBMessage *message = [[KBMessage alloc] initWithMember:@"Authentication Failed" andMessage:@"Please try again."];
        //[delegate displayFoursquareErrorMessage:message];
		[delegate displayFoursquareErrorMessage:@"Authentication Failed"];
        [message release];
    } else {
        [FlurryAPI logEvent:@"Logging in"];
        NSString *un = userName.text;
        NSString *pw = password.text;
        [[FoursquareAPI sharedInstance] doLoginUsername: un andPass:pw];	
        
        if (un)
        {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:un forKey:kUsernameDefaultsKey];
            
            DLog(@"Stored username: %@", un);
        }
        
        NSError *error = nil;
        [SFHFKeychainUtils storeUsername:un
                             andPassword:pw
                          forServiceName:@"Kickball" 
                          updateExisting:YES error:&error];
        
        KickballAppDelegate *appDelegate = (KickballAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate setupAuthenticatedUserAndPushNotifications];
        
		[delegate killLoginView];
        if([delegate respondsToSelector:@selector(doInitialDisplay)]){
            [delegate doInitialDisplay];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"signInComplete"
                                                            object:nil
                                                          userInfo:nil];
        //[self dismissModalViewControllerAnimated:true];
    }
}



- (void)dealloc {
	[delegate release];
    [super dealloc];
}


@end

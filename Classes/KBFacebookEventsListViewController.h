//
//  KBFacebookEventsListViewController.h
//  Kickball
//
//  Created by scott bates on 6/15/10.
//  Copyright 2010 Scott Bates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBFacebookViewController.h"


@interface KBFacebookEventsListViewController : KBFacebookViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UITableViewCell *searchCell;
    IBOutlet UITextField *searchbox;
    IBOutlet UITableViewCell *footerCell;
    IBOutlet UIView *noResultsView;
    NSDictionary *venues;
    //KBListType venuesTypeToDisplay;
    bool isSearchEmpty;
	UIButton *coverButton;
	
	BOOL doingLogin;
	NSMutableArray *eventsFeed;
}

@property (nonatomic, retain) UITableViewCell *searchCell;
@property (nonatomic, retain) NSDictionary *venues;

- (IBAction) searchOnKeywordsandLatLong;
- (IBAction) refresh: (UIControl *) button;
- (IBAction) addNewVenue;
- (IBAction) cancelKeyboard: (UIControl *) button;
- (IBAction) cancelTheKeyboard;
- (IBAction) cancelEdit;


@end

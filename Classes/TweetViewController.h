//
//  TweetViewController.h
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/12/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "yFrogImageDownoader.h"
#import "yFrogImageUploader.h"
#import "MGConnectionWrap.h"
#import "UserInfoView.h"

enum {
    kMessageTableSection      = 0,
    kActionTableSection       = 1
};

enum {
    kNextTwitSegmentIndex     = 0,
    kPrevTwitSegmentIndex     = 1
};

enum {
    kReplySegmentIndex        = 0,
    kFavoriteSegmentIndex     = 1,
    kForwardSegmentIndex      = 2,
    kDeleteSegmentIndex       = 3
};

enum {
    kViewTableSectionCount    = 2,
    kViewTableRowsAtSections  = 1
};

typedef enum {
	TVNoMVOperations,
	TVRetwit,
	TVForward,
    TVFavorite,
    TVDelete
} TVMessageViewSuspendedOperations;


@protocol TweetViewDelegate
// Must return count of tweets on my account
- (int)messageCount;

// Must return dictionary with message data
- (NSDictionary *)messageData:(int)index;
@end

@class MGTwitterEngine;

@interface TweetViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
                                                   UIActionSheetDelegate, UIAlertViewDelegate,
                                                   ImageUploaderDelegate, ImageDownoaderDelegate,
                                                   UIWebViewDelegate, UserInfoViewDelegate,
                                                   MFMailComposeViewControllerDelegate>
{
@private
    UISegmentedControl         *tweetNavigate;
    UISegmentedControl         *_actionSegment;
    UITableView                *contentTable;
	UIActionSheet                       *_progressSheet;    
    UserInfoView                        *_headView;
    UIView                              *_footerView;
    UIWebView                           *_webView;
    NSDictionary                        *_message;
    NSMutableDictionary                 *_imagesLinks;
	NSMutableArray                      *_connectionsDelegates;
    UIColor                             *_defaultTintColor;
    TVMessageViewSuspendedOperations     _suspendedOperation;
	BOOL                                 _isDirectMessage;
	int                                  _newLineCounter;
    int                                  _count;
    int                                  _currentMessageIndex;
    id <TweetViewDelegate>               _store;
    MGTwitterEngine                     *_twitter;
    NSString                            *_connectionIdentifier;
    BOOL                                 isFavorited, _isCurrentUserMessage;
    Class                                _dataSourceClass;
}

@property (nonatomic, retain) UIActionSheet *_progressSheet;
@property (nonatomic, retain) NSString *connectionIdentifier;
@property (nonatomic, assign) Class dataSourceClass;

@property (nonatomic, retain) IBOutlet UISegmentedControl *tweetNavigate;
@property (nonatomic, retain) IBOutlet UISegmentedControl *_actionSegment;
@property (nonatomic, retain) IBOutlet UITableView *contentTable;

- (id)initWithStore:(id <TweetViewDelegate>)store messageIndex:(int)index;
- (id)initWithStore:(id <TweetViewDelegate>)store;

// Actions
- (IBAction)tweetNavigate:(id)sender;
- (IBAction)actionSegmentClick:(id)sender;
- (IBAction)replyTwit;
- (IBAction)favoriteTwit;
- (IBAction)forwardTwit;
- (IBAction)deleteTwit;

- (void)receivedImage:(UIImage*)image sender:(ImageDownoader*)sender;
- (void)uploadedImage:(NSString*)yFrogURL sender:(ImageUploader*)sender;
- (void)movieFinishedCallback:(NSNotification*)aNotification;
- (void)playMovie:(NSString*)movieURL;

@end

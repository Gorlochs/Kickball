#import <UIKit/UIKit.h>

@class AccountManager, MGTwitterEngine, LoginController;

@interface AccountController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
@private
    BOOL                  _canAnimate;
	BOOL shouldShowTabControllerOnAutoLogin;
	UITableView *_tableAccounts;
    AccountManager       *_manager;
    MGTwitterEngine      *_twitter;
    NSString             *_credentialIdentifier;
	LoginController	 *loginController;
}

@property (nonatomic) BOOL canAnimate;
@property (nonatomic, readonly) AccountManager* accountManager;
@property (nonatomic, retain) IBOutlet UITableView *_tableAccounts;

- (id)init;

- (id)initWithManager:(AccountManager*)manager;

- (IBAction)clickAdd;

- (IBAction)clickEdit;

+ (void)showAccountController:(UINavigationController*)navigationController;

@end

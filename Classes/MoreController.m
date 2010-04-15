//
//  MoreController.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 11/22/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "SearchProvider.h"
#import "MoreController.h"
#import "SearchController.h"
#import "MyTweetViewController.h"
#import "FollowersController.h"
#import "SettingsController.h"
#import "AboutController.h"
#import "AccountManager.h"

@interface MoreItem : NSObject
{
@private
    NSString    *_title;
    NSString    *_nibName;
    UIImage     *_icon;
    Class        _controllerClass;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *nibName;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, assign) Class controllerClass;

+ (MoreItem*)item;

@end

@implementation MoreItem

@synthesize title = _title;
@synthesize nibName = _nibName;
@synthesize icon = _icon;
@synthesize controllerClass = _controllerClass;

+ (MoreItem*)item
{
    return [[[MoreItem alloc] init] autorelease];
}

- (void)dealloc
{
    self.title = nil;
    self.nibName = nil;
    self.icon = nil;
    self.controllerClass = nil;
    [super dealloc];
}

@end

//
// MoreController implementation
//
@interface MoreController(Private)
- (void)initData;
- (UIViewController*)controllerForItem:(MoreItem*)item;
- (void)updateSavedSearches;
@end

@implementation MoreController

@synthesize searchProvider = _searchProvider;

- (id)initWithStyle:(UITableViewStyle)style 
{
    YFLog(@"MORE_CONTOLLER");
    if (self = [super initWithStyle:style]) 
    {
        YFLog(@"INIT MORE CONTROLLER");
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
		isSavedSearchesLoaded = NO;
        
        [self initData];
    }
    return self;
}

- (void)dealloc 
{
    if (self.searchProvider)
    {
        self.searchProvider.delegate = nil;
        self.searchProvider = nil;
    }
    
    [SearchProvider sharedProviderRelease];
    
    [_moreItems release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:5] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parentViewController.navigationItem.title = NSLocalizedString(@"More", @"");
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    
	[self updateSavedSearches];
	
	NSEnumerator *moreItemsEnumerator = [_moreItems objectEnumerator];
	id moreItem = nil;
	while (nil != (moreItem = [moreItemsEnumerator nextObject]))
	{
		MoreItem *theItem = (MoreItem *)moreItem;
		if ([[theItem title] isEqualToString:@"Followers"])
		{
			NSString *theTitle = [[NSString alloc] initWithFormat:@"%@ (%@)", NSLocalizedString([theItem title], @""),
						[[[AccountManager manager] loggedUserAccount] valueForKey:@"followers_count"]];
			theItem.title = theTitle;
			[theTitle release];
		}
		else if ([[theItem title] isEqualToString:@"Following"])
		{
			NSString *theTitle = [[NSString alloc] initWithFormat:@"%@ (%@)", NSLocalizedString([theItem title], @""),
						[[[AccountManager manager] loggedUserAccount] valueForKey:@"friends_count"]];
			theItem.title = theTitle;
			[theTitle release];
		}
	}
	
    [self.tableView reloadData];
}

- (SearchProvider *)searchProvider
{
	if (nil == _searchProvider)
	{
		_searchProvider = [SearchProvider sharedProviderUsingDelegate:self];
	}
	
	return _searchProvider;
}

#pragma mark UITableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([self.searchProvider allQueries] && ([self.searchProvider allQueries] > 0)) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [_moreItems count];
    else if (section == 1 && isSavedSearchesLoaded)
        return [[self.searchProvider allQueries] count];
	else if (section == 1 && !isSavedSearchesLoaded)
		return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"MoreViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellIdentifier] autorelease];
    
    // Controller cells
    if (indexPath.section == 0)
    {
        MoreItem *item = [_moreItems objectAtIndex:indexPath.row];
        if (item)
        {
            cell.textLabel.text =  item.title;
            cell.imageView.image = item.icon;
        }
    }
    // Saved search cells
    else
    {	
		if (0 == [[self.searchProvider allQueries] count] && !isSavedSearchesLoaded)
		{
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@""] autorelease];
			
			UILabel *loadingText = [[[UILabel alloc] initWithFrame:cell.contentView.frame] autorelease];
			[loadingText setCenter:CGPointMake(loadingText.center.x + 7, cell.contentView.frame.size.height / 2.0)];
			loadingText.text = NSLocalizedString(@"Loading saved searches...", @"");
			loadingText.font = [UIFont boldSystemFontOfSize:16];
			
			UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc]
						initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
			[spinner setCenter:CGPointMake(cell.contentView.frame.size.width - spinner.frame.size.width / 2 - 7,
						cell.contentView.frame.size.height / 2.0)];
			[spinner startAnimating];
			
			[cell.contentView addSubview:loadingText];
			[cell.contentView addSubview:spinner];
						
			return cell;
		}		
		
        cell.imageView.image = nil;
        if (indexPath.row < [[self.searchProvider allQueries] count])
            cell.textLabel.text = [[self.searchProvider allQueries] objectAtIndex:indexPath.row];
        else
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MoreItem *item = [_moreItems objectAtIndex:indexPath.row];
        if (item)
        {
            UIViewController *controller = [self controllerForItem:item];
            if (controller)
                [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSAssert(cell != nil, @"Cell is nil");
        SearchController *searchController = [[SearchController alloc] initWithQuery:cell.textLabel.text];
        [self.navigationController pushViewController:searchController animated:YES];
        [searchController release];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if (section == 1)
        return NSLocalizedString(@"Saved Searches", @"");
    return nil;
}

#pragma mark SearchProvider Delgate methods
- (void)searchProviderDidUpdated
{
	isSavedSearchesLoaded = YES;
    [self.tableView reloadData];
}

@end

//
// Private implementation
//
@implementation MoreController(Private)

- (void)initData
{
    if (_moreItems)
        [_moreItems release];
    
    _moreItems = [[NSMutableArray alloc] init];
    
    MoreItem *item = nil;
    
    item = [MoreItem item];
    item.title = @"My Tweets";
    item.nibName = @"UserMessageList";
    item.icon = [UIImage imageNamed:@"my-tweets.png"];
    item.controllerClass = [MyTweetViewController class];
    [_moreItems addObject:item];
    	
    item = [MoreItem item];
    item.title = @"Followers";
    item.nibName = @"UserMessageList";
    item.icon = [UIImage imageNamed:@"followers.png"];
    item.controllerClass = [FollowersController class];
    [_moreItems addObject:item];
    
    item = [MoreItem item];
    item.title = @"Following";
    item.nibName = @"UserMessageList";
    item.icon = [UIImage imageNamed:@"following.png"];
    item.controllerClass = [FollowingController class];    
    [_moreItems addObject:item];

    item = [MoreItem item];
    item.title = @"Search";
    item.nibName = @"SearchController";
    item.icon = [UIImage imageNamed:@"search.png"];
    item.controllerClass = [SearchController class];
    [_moreItems addObject:item];
    
    item = [MoreItem item];
    item.title = @"Settings";
    item.nibName = @"SettingsView";
    item.icon = [UIImage imageNamed:@"settings.png"];
    item.controllerClass = [SettingsController class];
    [_moreItems addObject:item];    
    
    item = [MoreItem item];
    item.title = @"About";
    item.nibName = @"About";
    item.icon = [UIImage imageNamed:@"about.png"];
    item.controllerClass = [AboutController class];
    [_moreItems addObject:item];
}

- (UIViewController*)controllerForItem:(MoreItem*)item
{
    UIViewController *theController = [[[item.controllerClass alloc] initWithNibName:item.nibName bundle: nil] autorelease];
    theController.title = NSLocalizedString(item.title, @"");
    return theController;
}

- (void)updateSavedSearches
{
	[self.searchProvider update];
}

@end
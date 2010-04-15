//
//  SearchController.m
//  Tweetero
//
//  Created by Sergey Shkrabak on 9/18/09.
//  Copyright 2009 Codeminders. All rights reserved.
//

#import "TweetterAppDelegate.h"
#import "SearchController.h"
#import "CustomImageView.h"
#import "ImageLoader.h"
#import "TwLabel.h"
#include "util.h"

// Tag identifire
#define TAG_IMAGE               1
#define TAG_FROM                2
#define TAG_TO                  3
#define TAG_TEXT                4
// Geometry metrics
#define BORDER_WIDTH            5
#define IMAGE_SIDE              48
#define LABLE_HEIGHT            15
#define LABLE_WIDTH             250

#define MAX_SEARCH_COUNT        20
#define START_AT_PAGE           1

static NSComparisonResult searchResultsComparator(id searchItem1, id searchItem2, void *context)
{
	if (![searchItem1 isKindOfClass:[NSDictionary class]] || ![searchItem2 isKindOfClass:[NSDictionary class]])
	{
		return NSOrderedSame;
	}
	
	NSDictionary *dictionary1 = (NSDictionary *)searchItem1;
	NSDictionary *dictionary2 = (NSDictionary *)searchItem2;
	
	NSDate *date1 = [dictionary1 valueForKey:@"created_at"];
	NSDate *date2 = [dictionary2 valueForKey:@"created_at"];
	
	if (nil == date1 || nil == date2)
	{
		return NSOrderedSame;
	}
	
	NSComparisonResult comparisionResult = [date1 compare:date2];
	if (NSOrderedAscending == comparisionResult)
	{
		return NSOrderedDescending;
	}
	
	if (NSOrderedDescending == comparisionResult)
	{
		return NSOrderedAscending;
	}
		
	return NSOrderedSame;
}

@interface SearchController (Private)

- (UITableViewCell *)createSearchResultCell:(UITableView*)tableView more:(BOOL)isMore;
- (void)setCellData:(UITableViewCell *)cell data:(NSDictionary *)result;
- (void)clearCell:(UITableViewCell *)cell;
- (void)updateActionButton;
- (void)reloadData;
- (void)updateSearch;
- (void)activateIndicator:(BOOL)activate;
- (void)activateActionButton:(BOOL)activate;

@end

@implementation SearchController

@synthesize searchProvider = _searchProvider;
@synthesize query = _query;
@synthesize _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _indicator = [[TwActivityIndicator alloc] init];
        _result = nil;
        _pageNum = START_AT_PAGE;
        _showSearchResult = NO;
        _emptyString = @"";
        self.query = @"";
    }
    return self;
}

- (id)initWithQuery:(NSString *)query
{
    if ((self = [self initWithNibName:@"SearchController" bundle:nil]))
    {
        [self activateActionButton:NO];
        self.query = query;
    }
    return self;
}

- (void)dealloc
{
    YFLog(@"DEALLOC SEARCH CONTROLLER");
    self.query = nil;
    if (self.searchProvider) {
        [self.searchProvider closeSearch];
        self.searchProvider.delegate = nil;
        self.searchProvider = nil;
    }
    [TweetterAppDelegate decreaseNetworkActivityIndicator];
    [_result release];
    [_searchBar release];
	_searchBar = nil;
    [_indicator release];
    [_searchController release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.searchProvider = [SearchProvider sharedProviderUsingDelegate:self];
    
    _pageNum = START_AT_PAGE;
    _searchBar.text = self.query;
    self.navigationItem.titleView = _searchBar;
    //if (self.query != nil)
    if (_showSearchResult == NO)
        [_searchBar becomeFirstResponder];
    
    if ([self.searchProvider isEndOfSearch] == NO)
        [self activateIndicator:YES];
    [self updateActionButton];
    [self reloadData];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    //[self clear];
    //[self reloadData];
    
    [self activateIndicator:NO];
    // Reset delegate in searchProvider object
    //if (self.searchProvider) 
    //{
        //self.searchProvider.delegate = nil;
        //self.searchProvider = nil;
    //}
    [super viewDidDisappear:animated];
}

- (IBAction)clickActionButton
{
    [self activateActionButton:NO];
    if ([self.searchProvider hasQuery:self.query])
        [self.searchProvider removeQuery:self.query];
    else
        [self.searchProvider saveQuery:self.query forId:0];
}

- (void)clear
{
    if (_result)
        [_result release];
    _result = nil;
}

#pragma mark UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [TweetterAppDelegate increaseNetworkActivityIndicator];
    [self clear];
    _emptyString = @"";
    [self.tableView reloadData];
    [self activateIndicator:YES];
    
    _result = [NSMutableArray new];
    
    [self updateSearch];
    [_searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.query = searchText;
    [self updateActionButton];
}

#pragma mark SearchProvider Delegate
- (void)searchDidEnd:(NSArray *)recievedData forQuery:(NSString *)query
{
    _emptyString = @"";
    if (recievedData && [recievedData count] > 0)
	{
        if (!_result)
		{
			_result = [NSMutableArray new];
		}
		
        [_result addObjectsFromArray:recievedData];
    }
	
    if ([self.searchProvider isEndOfSearch])
	{
		[TweetterAppDelegate decreaseNetworkActivityIndicator];
		[self activateIndicator:NO];
		
        NSLog(@"search result: %@", _result);
        NSLog(@"search result length: %d", [_result count]);
		NSArray *theSortedArray = [_result sortedArrayUsingFunction:searchResultsComparator context:NULL];
        NSLog(@"sorted search result: %@", theSortedArray);
        NSLog(@"sorted search result length: %d", [theSortedArray count]);
		[_result release];
		_result = [[NSMutableArray alloc] initWithArray:theSortedArray];
    }
	
    [self reloadData];
}

- (void)searchDidEndWithError:(NSString *)query
{
    if ([self.searchProvider isEndOfSearch]) {
        [TweetterAppDelegate decreaseNetworkActivityIndicator];
        [self activateIndicator:NO];
    }
    _emptyString = NSLocalizedString(@"Search_NotFound", @"");
    _hasConnectionError = YES;
}

- (void)searchProviderDidUpdated
{
    [self updateActionButton];
    [self activateActionButton:YES];
}

#pragma mark UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 1;
    
    if (_result)
    {
        count = [_result count];
        if (count == 0)
            count = 1;
        else if (count == MAX_SEARCH_COUNT * _pageNum)
            count++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    BOOL isMoreCell = YES;
    
    if (_result && [_result count] > 0) 
    {
        if (indexPath.row < [_result count])
            isMoreCell = NO;
        cell = [self createSearchResultCell:tableView more:isMoreCell];
        if (!isMoreCell) 
        {
            NSDictionary *searchResult = [_result objectAtIndex:indexPath.row];
            [self setCellData:cell data:searchResult];
        }
    }
    else
    {
        cell = [self createSearchResultCell:tableView more:NO];
        [self clearCell:cell];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        if (!_result)    
            cell.textLabel.text = _hasConnectionError ? NSLocalizedString(@"Failed to create connection.", @"") : @"";
        else
            cell.textLabel.text = _emptyString;
            
    }
    return cell;
}

#pragma mark UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row == [_result count])
    {
        ++_pageNum;
        [self activateIndicator:YES];
        [self updateSearch];
    }
    else
    {
        _showSearchResult = YES;
        TweetViewController *view = [[TweetViewController alloc] initWithStore:self messageIndex:indexPath.row];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark TweetViewDelegate
- (int)messageCount
{
    return [_result count];
}

// Must return dictionary with message data
- (NSDictionary *)messageData:(int)index
{
    return [_result objectAtIndex:index];
}

@end

@implementation SearchController (Private)

- (UITableViewCell *)createSearchResultCell:(UITableView*)tableView more:(BOOL)isMore
{
    NSString *kCellIdentifier = isMore ? @"MoreSearchCell" : @"SearchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell)
    {
        if (cell == nil)
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCellIdentifier] autorelease];
        
        if (isMore)
        {
            UILabel *more = [[UILabel alloc] initWithFrame:CGRectMake(135, 10, 200, 20)];
            more.text = NSLocalizedString(@"More...", @"");
            more.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:more];
            [more release];            
        }
        else
        {
            // Create avatar image
            CustomImageView *avatar = [[CustomImageView alloc] initWithFrame:CGRectMake(BORDER_WIDTH, BORDER_WIDTH, IMAGE_SIDE, IMAGE_SIDE)];
            avatar.tag = TAG_IMAGE;
            avatar.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:avatar];
            [avatar release];
            
            UILabel *label = nil;
            
            // Create "From" label
            label = [[UILabel alloc] initWithFrame:CGRectMake(BORDER_WIDTH * 2 + IMAGE_SIDE, BORDER_WIDTH, LABLE_WIDTH, LABLE_HEIGHT)];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.tag = TAG_FROM;
            label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:label];
            [label release];
            
            // Create "Text" label
            label = [[TwLabel alloc] initWithFrame:CGRectMake(BORDER_WIDTH * 2 + IMAGE_SIDE, BORDER_WIDTH, LABLE_WIDTH, LABLE_HEIGHT)];
            label.font = [UIFont systemFontOfSize:13];
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.numberOfLines = 0;
            label.tag = TAG_TEXT;
            label.backgroundColor = [UIColor clearColor];
            label.opaque = NO;
            [cell.contentView addSubview:label];
            [label release];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)setCellData:(UITableViewCell *)cell data:(NSDictionary *)result
{
    int doubleBorder = BORDER_WIDTH << 1;
    int height = 0;

    CustomImageView *avatar = (CustomImageView*)[cell viewWithTag:TAG_IMAGE];

    UILabel *label = (UILabel*)[cell viewWithTag:TAG_FROM];
    
    NSDictionary *user_info = [result objectForKey:@"user"];
    if (user_info) {
        id profileImageUrl = [user_info objectForKey:@"profile_image_url"];
        if (!isNullable(profileImageUrl))
            avatar.image = [[ImageLoader sharedLoader] imageWithURL:profileImageUrl];
        label.text = [user_info objectForKey:@"screen_name"];
    } else {
        label.text = @"Unknown";
        avatar.image = nil;
    }
    height = label.frame.size.height;
    
    int fromHeight = label.frame.size.height;
    
    label = (TwLabel*)[cell viewWithTag:TAG_TEXT];
    label.text = DecodeEntities([result objectForKey:@"text"]);
    label.frame = CGRectMake(BORDER_WIDTH * 2 + IMAGE_SIDE, fromHeight + BORDER_WIDTH, LABLE_WIDTH, LABLE_HEIGHT);
    
    ((TwLabel*)label).mask = self.query;
    [label sizeToFit];
    
    height += label.frame.size.height;
    height += BORDER_WIDTH;
    
    if (height < (avatar.frame.size.height + doubleBorder))
        height = avatar.frame.size.height + doubleBorder;
    else
        height += BORDER_WIDTH;
    
    CGRect rc = cell.frame;
    rc.size.height = height;
    [cell setFrame:rc];
}

- (void)clearCell:(UITableViewCell *)cell
{
    CustomImageView *avatar = (CustomImageView*)[cell viewWithTag:TAG_IMAGE];
    avatar.image = nil;
    UILabel *label = (UILabel*)[cell viewWithTag:TAG_FROM];
    label.text = @"";
    label = (UILabel*)[cell viewWithTag:TAG_TEXT];
    label.text = @"";
}

// Update action button
- (void)updateActionButton
{
    if (self.searchProvider)
    {
        UIBarButtonSystemItem systemItem;
        
        if ([self.searchProvider hasQuery:self.query])
            systemItem = UIBarButtonSystemItemTrash;
        else
            systemItem = UIBarButtonSystemItemAdd;
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: systemItem target: self action: @selector(clickActionButton)];
        item.enabled = YES;
        self.navigationItem.rightBarButtonItem = item;
        [item release];
    }
    else
    {
        [self activateActionButton:NO];
    }
}

// Reload table data
- (void)reloadData
{
    [(UITableView*)self.view reloadData];
}

// Update search
- (void)updateSearch
{
    _hasConnectionError = NO;
    [self.searchProvider search:self.query fromPage:_pageNum count:MAX_SEARCH_COUNT];
}

// Activate/Deactivate progress indicator
- (void)activateIndicator:(BOOL)activate
{
    if (activate)
    {
        [_indicator.messageLabel setText:NSLocalizedString(@"Search_IndicatorText", @"")];
        [_indicator show];
    }
    else
    {
        [_indicator hide];
    }
}

// Activate/Deactivate action button
- (void)activateActionButton:(BOOL)activate
{
    self.navigationItem.rightBarButtonItem.enabled = activate;
}

@end

//
//  EventListViewController.m
//  Argos
//
//  Created by Francis Tseng on 1/27/14.
//  Copyright (c) 2014 Argos. All rights reserved.
//

#import "EventListViewController.h"
#import "EventDetailViewController.h"
#import "SWTableViewCell.h"
#import "ArgosClient.h"

@interface EventListViewController () {
    NSMutableArray *_events;
    NSString *_endpoint;
}

@end

@implementation EventListViewController

- (id)initWithTitle:(NSString*)title endpoint:(NSString*)endpoint
{
    self = [super init];
    if (self) {
        self.navigationItem.title = title;
        _endpoint = endpoint;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Hack to do back buttons w/o text.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain target:nil action:nil];
 
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
    
    _events = [[NSMutableArray alloc] init];
    [self loadData];
    
    // Setup Pull-To-Refresh
    if (self.refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc]
                                           initWithFrame:CGRectMake(0.0f,
                                                                    0.0f - self.tableView.bounds.size.height,
                                                                    self.view.frame.size.width,
                                                                    self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        self.refreshHeaderView = view;
    }
    
    
    // Set cell separator to full width, if necessary.
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)loadData
{
    [[ArgosClient sharedClient] GET:_endpoint parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        
        // Filter out existing items.
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:responseObject];
        [newItems removeObjectsInArray:_events];
        
        [_events addObjectsFromArray:newItems];
        [self.tableView reloadData];
        
        self.dateLastUpdated = [NSDate date];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection" message:@"Unable to reach home" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
            [UIColor colorWithRed:0.478 green:0.757 blue:0.471 alpha:1.0]
            icon:[UIImage imageNamed:@"favorite"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
            [UIColor colorWithRed:0.478 green:0.757 blue:0.471 alpha:1.0]
            icon:[UIImage imageNamed:@"watch"]];
        
        [rightUtilityButtons sw_addUtilityButtonWithColor:
            [UIColor colorWithRed:0.478 green:0.757 blue:0.471 alpha:1.0]
            icon:[UIImage imageNamed:@"share"]];
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:CellIdentifier
                                        containingTableView:tableView
                                        leftUtilityButtons:leftUtilityButtons
                                        rightUtilityButtons:rightUtilityButtons];
        cell.delegate = self;
    }
    
    // Configure the cell...
    NSDictionary *tempDict = [_events objectAtIndex:indexPath.row];
    cell.textLabel.text = [tempDict objectForKey:@"title"];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.imageView.image = [UIImage imageNamed:@"sample"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[[EventDetailViewController alloc] init] animated:YES];
}

#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            UIButton* button = [[cell rightUtilityButtons] objectAtIndex:index];
            if (button.tag != 1) {
                [button setImage:[UIImage imageNamed:@"favorited"] forState:UIControlStateNormal];
                [button setTag:1];
            } else {
                [button setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
                [button setTag:0];
            }
            
            //[cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            UIButton* button = [[cell rightUtilityButtons] objectAtIndex:index];
            if (button.tag != 1) {
                [button setImage:[UIImage imageNamed:@"watched"] forState:UIControlStateNormal];
                [button setTag:1];
            } else {
                [button setImage:[UIImage imageNamed:@"watch"] forState:UIControlStateNormal];
                [button setTag:0];
            }
            
            //[cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 2:
        {
            NSLog(@"share");
        }
        default:
            break;
    }
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	self.reloading = YES;
    [self loadData];
    [self doneLoadingTableViewData];
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	self.reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
	[self performSelectorOnMainThread:@selector(reloadTableViewDataSource) withObject:nil waitUntilDone:NO];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
	return self.reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
	return self.dateLastUpdated; // should return date data source was last changed
    
}


@end

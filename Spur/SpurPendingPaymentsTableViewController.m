//
//  SpurPendingPaymentTableViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/19/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurPendingPaymentsTableViewController.h"
#import "SpurService.h"
#import "SpurAppDelegate.h"
#import "SpurExpandedPendingPaymentViewController.h"

@interface SpurPendingPaymentsTableViewController ()

@property (strong, nonatomic) SpurService *spurService;


@end

@implementation SpurPendingPaymentsTableViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


// mzoufaly add the following in order to enforce login


-(void)fetchDataFromAzure :(UIRefreshControl*)refresh
{
    // ZZZ Change this line for each new view
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    id userId = [delegate getUserId];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId == '%@'", userId]];
    
    
    [self.spurService refreshDataOnSuccess:^{
        NSLog(@"Get all requests that have the user as the requestor!");
        [self.tableView reloadData];
        [refresh endRefreshing];
    } :predicate];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ZZZ Change this line for each new view
    self.spurService = [[SpurService alloc]initWithTable:@"itemaccepted"];
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Spur it on..."];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self fetchDataFromAzure :refresh];
    
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
    return [self.spurService.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ZZZ Change this line for each new view
    static NSString *CellIdentifier = @"PendingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    id item = [self.spurService.items objectAtIndex:indexPath.row];
    NSLog(@"%@\n",item);
    
    BOOL accepted = [[item objectForKey:@"accepted"] boolValue];
    if(accepted)
    {
        UIButton *payViewButton = [[UIButton alloc]initWithFrame:CGRectMake(250,0,50,30)];
        [payViewButton setBackgroundColor:[UIColor blueColor]];
        [cell.contentView addSubview:payViewButton];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ by %@",[item objectForKey:@"bestOffer"],[item objectForKey:@"userId"]];
    
    
    return cell;
}

#pragma mark - Table view delegate

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self fetchDataFromAzure :refresh];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                             [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SpurExpandedPendingPaymentViewController * dvc = (SpurExpandedPendingPaymentViewController*)[segue destinationViewController];
    NSLog(@"The sender is %@",sender);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //Get the selected object in order to fill out the detail view
    id item = [self.spurService.items objectAtIndex:indexPath.row];
    NSLog(@"%@\n",item);
    [dvc setConfirmedOffer:item];
    
}

@end
//
//  SpurViewRequestsTableViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurIncomingRequestsTableViewController.h"
#import "SpurService.h"
#import "QuickDialog.h"
#import "SpurExpandedIncomingRequestViewController.h"

@interface SpurIncomingRequestsTableViewController ()


// Private properties
@property (strong, nonatomic) SpurService *spurService;



@end

@implementation SpurIncomingRequestsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.spurService = [[SpurService alloc]initWithTable:@"itemrequest"];
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Spur it on..."];
    
    [refresh addTarget:self
              action:@selector(refreshView:)
            forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.spurService refreshDataOnSuccess:^{
        [self.tableView reloadData];
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
    return [self.spurService.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RequestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    id item = [self.spurService.items objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    
    
    return cell;
}

#pragma mark - Table view delegate

 -(void)refreshView:(UIRefreshControl *)refresh {
     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
     
     [self.spurService refreshDataOnSuccess:^{
         NSLog(@"Pull to refresh done!\n");
         [self.tableView reloadData];
         [refresh endRefreshing];
     }];

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
    SpurExpandedIncomingRequestViewController * dvc = (SpurExpandedIncomingRequestViewController*)[segue destinationViewController];
    NSLog(@"The sender is %@",sender);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //Get the selected object in order to fill out the detail view
    id item = [self.spurService.items objectAtIndex:indexPath.row];

    NSLog(@"ITEM IS %@\n",item);
    [dvc setRequestID:[item objectForKey:@"id"]];
    
}

@end

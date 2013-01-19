//
//  SpurViewOffersTableViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurIncomingOffersTableViewController.h"
#import "SpurExpandedIncomingOfferViewController.h"
#import "SpurAppDelegate.h"
#import "SpurService.h"


@interface SpurIncomingOffersTableViewController ()
@property (nonatomic,retain) SpurService *spurService;
@end

@implementation SpurIncomingOffersTableViewController
@synthesize  requestId;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


// mzoufaly add the following in order to enforce login

//ZZZ The user must be logged on to do anything on this page. It should be impossible to get here otherwise
- (void)viewDidAppear:(BOOL)animated
{
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    // If user is already logged in, no need to ask for auth
    if ([delegate getUserId]== nil)
    {
        // We want the login view to be presented after the this run loop has completed
        // Here we use a delay to ensure this.
        [self performSelector:@selector(login) withObject:self afterDelay:0.1];
    }
}


- (void) login
{
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    
    
    UINavigationController *controller =
    [self.spurService.client
     loginViewControllerWithProvider:@"google"
     completion:^(MSUser *user, NSError *error) {
         
         
         if (error) {
             NSLog(@"Authentication Error: %@", error);
             // Note that error.code == -1503 indicates
             // that the user cancelled the dialog
         } else {
             // No error, so load the data
             [self.spurService refreshDataOnSuccess:^{
                 [delegate setUserId:self.spurService.client.currentUser.userId];
                 
                 NSLog(@"Rock on!\n");
                 
                 //  [self.tableView reloadData];
             }];
         }
         
         
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

-(void)fetchDataFromAzure :(UIRefreshControl*)refresh
{
    // ZZZ Change this line for each new view
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"requestId == '%@'", self.requestId]];
    
    
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
    self.spurService = [[SpurService alloc]initWithTable:@"itemoffer"];
    
    
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
    static NSString *CellIdentifier = @"OfferCell";
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
    SpurExpandedIncomingOfferViewController * dvc = (SpurExpandedIncomingOfferViewController*)[segue destinationViewController];
    NSLog(@"The sender is %@",sender);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //Get the selected object in order to fill out the detail view
    id item = [self.spurService.items objectAtIndex:indexPath.row];
    
    [dvc setRequestId:self.requestId];
    [dvc setOffer:item];

    
    
}

@end

//
//  SpurAccepterOfferViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurExpandedPendingPaymentViewController.h"
#import "SpurService.h"
#import "SpurAppDelegate.h"

#define NUM_ROWS 4
@interface SpurExpandedPendingPaymentViewController ()
@property (strong, nonatomic) SpurService *spurService;
@property (strong, nonatomic) id requestee;

@end

@implementation SpurExpandedPendingPaymentViewController
@synthesize confirmedOffer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.spurService = [[SpurService alloc]initWithTable:@"user"];
	// ZZZ Change this line for each new view
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"deviceToken == '%@'", [confirmedOffer objectForKey:@"requesteeId"]]];
    
    
    [self.spurService refreshDataOnSuccess:^{
        NSLog(@"Get all requests that have the user as the requestor!");
        if([self.spurService.items count] != 0 && self.spurService.items)
            self.requestee = [self.spurService.items objectAtIndex:0];
        
        [self.tableView reloadData];
    } :predicate];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0,0,320,50)];
    UILabel * lbl = [[UILabel alloc]initWithFrame:CGRectMake(200,50,100,50)];
    lbl.text = @"Actions to take for the transaction";
    [v addSubview:lbl];
    return v;

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        NSLog(@"Sel 0");
    
    }
    else if (indexPath.row ==1 )
    {
        NSLog(@"Sel 1");
    }
    else if (indexPath.row ==2 )
    {
        NSLog(@"E-mail");

    }
    else
    {
        NSLog(@"Pay with Venmo");
 
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!self.requestee)
        return 0;
    return 1;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(!self.requestee)
        return 0;
    return NUM_ROWS;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"Call %@\n",[self.requestee objectForKey:@"phone"]];
    }
    else if (indexPath.row ==1 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"Message %@\n",[self.requestee objectForKey:@"phone"]];
    }
    else if (indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"Email %@\n",[self.requestee objectForKey:@"email"]];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"VenmoCell"];
        
    }
    return cell;
}


@end

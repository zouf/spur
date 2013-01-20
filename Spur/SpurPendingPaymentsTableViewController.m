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


#define NAME_TAG 100
#define BUY_SELL 101
#define PRICE 102
#define DESCRIPTION 103
#define TIME 104


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
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"requesteeID == '%@'", userId]];
    
    
    [self.spurService refreshDataOnSuccess:^{
        NSLog(@"Get all requests that have the user as the requestor!");
        [self.tableView reloadData];
        [refresh endRefreshing];
    } :predicate];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *navigationImage = [UIImage imageNamed:@"Transactions@2x.png"];
    CGImageRef imageRef = CGImageCreateWithImageInRect(navigationImage.CGImage, CGRectMake(0, 0, 640, 88));
    navigationImage = [UIImage imageWithCGImage:imageRef
                                          scale:2.0
                                    orientation:UIImageOrientationUp];
    [self.navigationController.navigationBar setBackgroundImage:navigationImage forBarMetrics:UIBarMetricsDefault];
    CGImageRelease(imageRef);
    
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
    return ([ self.spurService.items count]  <= 7) ? 7 : [ self.spurService.items count];
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
    
    
    
    UIImage *cellBackground = [UIImage imageNamed:@"Tablebackground@2x"];
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:cellBackground]];
    
    
    UILabel * name = (UILabel*)[cell viewWithTag:NAME_TAG];
    UILabel * buySell = (UILabel*)[cell viewWithTag:BUY_SELL];
    UILabel * price = (UILabel*)[cell viewWithTag:PRICE];
    UILabel *description = (UILabel*)[cell viewWithTag:DESCRIPTION];
    UILabel *time = (UILabel*)[cell viewWithTag:TIME];
    
    
    
    if([self.spurService.items count] <= 7 && indexPath.row +1  > ([self.spurService.items count]) ) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        name.text = @"";
        time.text = @"";
        buySell.text = @"";
        price.text = @"";
        description.text = nil;
        UIImage *cellBackground = [UIImage imageNamed:@"Tableemptybackground@2x"];
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:cellBackground]];
        
    } else {

        id item = [self.spurService.items objectAtIndex:indexPath.row];

        
        
        NSLog(@"%@\n", item);
    
        NSString *theName = [item objectForKey:@"userName"];
        BOOL borrow = [[item objectForKey:@"borrow"] boolValue];
        
        if (![theName  isEqual:[NSNull null]])
        {
            if(!borrow)
                name.text = [NSString stringWithFormat:@"Someone buying:\n"];//, [item objectForKey:@"userName"] ];
            else
                name.text = [NSString stringWithFormat:@"Someone borrowing:\n"];// [item objectForKey:@"userName"] ];
            
            
        }
        NSDate *now = [[NSDate alloc] init];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:s"];
        
        NSString* dateStringFromDatabase = [item objectForKey:@"posttime"];
        
        NSDate* dateFromString = [outputFormatter dateFromString:dateStringFromDatabase];
        NSString* a = [outputFormatter stringFromDate:now];
        NSDate* b = [outputFormatter dateFromString:a];
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        
        unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
        
        NSDateComponents *components = [gregorian components:unitFlags fromDate:dateFromString
                                                      toDate:b options:0];
        
        int hours = [components hour];
        int minutes = [components minute];
        
        
        if(hours)
            time.text =  [NSString stringWithFormat:@"%dh %dm ago\n",hours,minutes];
        else if (minutes)
            time.text =  [NSString stringWithFormat:@"%dm ago\n",minutes];
        else
            time.text =  [NSString stringWithFormat:@"Moments ago\n"];
        
        
        description.text = [item objectForKey:@"name"];
        buySell.text = @"";
        /*if(borrow)
         buySell.text = @"Borrow";
         else
         buySell.text = @"Buy";*/
        price.text = [item objectForKey:@"price"];
    }
    return cell;
}

#pragma mark - Table view delegate

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    [self fetchDataFromAzure :refresh];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last spurred on %@",
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
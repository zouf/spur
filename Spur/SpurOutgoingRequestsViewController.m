//
//  SpurOutgoingRequestsViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/19/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//


#import "SpurOutgoingRequestsViewController.h"
#import "SpurAppDelegate.h"
#import "SpurService.h"
#import "SpurIncomingOffersTableViewController.h"

#define ITEM_NAME 100
#define TIME 101
#define PRICE 102
#define BORROW_BUY 103
#define NUMBER_OF_OFFERS 104

@interface SpurOutgoingRequestsViewController ()



@property (nonatomic, retain) SpurService *spurService;
@property (nonatomic, retain) SpurService *spurNumOffers;


@end

@implementation SpurOutgoingRequestsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)fetchDataFromAzure :(UIRefreshControl*)refresh
{
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"userId == '%@'", [delegate getUserId]]];

   
    [self.spurService refreshDataOnSuccess:^{
        NSLog(@"Get all requests that have the user as the requestor!");
        [self.tableView reloadData];
        [refresh endRefreshing];
    } :predicate];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    UIImage *navigationImage = [UIImage imageNamed:@"My_Spurs@2x.png"];
    CGImageRef imageRef = CGImageCreateWithImageInRect(navigationImage.CGImage, CGRectMake(0, 0, 640, 88));
    navigationImage = [UIImage imageWithCGImage:imageRef
                                          scale:2.0
                                    orientation:UIImageOrientationUp];
    [self.navigationController.navigationBar setBackgroundImage:navigationImage forBarMetrics:UIBarMetricsDefault];
    CGImageRelease(imageRef);
    
    self.spurService = [[SpurService alloc]initWithTable:@"itemrequest"];
    self.spurNumOffers = [[SpurService alloc]initWithTable:@"itemoffer"];


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
    static NSString *CellIdentifier = @"OutRequestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    UIImage *cellBackground = [UIImage imageNamed:@"Tablebackground@2x.png"];
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:cellBackground]];
    
    
    UILabel * nameLabel = (UILabel*)[cell viewWithTag:ITEM_NAME];
    UILabel * borrowBuyLabel = (UILabel*)[cell viewWithTag:BORROW_BUY];
    UILabel * priceLabel = (UILabel*)[cell viewWithTag:PRICE];
    UILabel *numOffersLabel = (UILabel*)[cell viewWithTag:NUMBER_OF_OFFERS];
    UILabel *timeLabel = (UILabel*)[cell viewWithTag:TIME];
    
    
    
    if([self.spurService.items count] <= 7 && indexPath.row +1  > ([self.spurService.items count]) ) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        nameLabel.text = @"";
        priceLabel.text = @"";
        timeLabel.text = @"";
        numOffersLabel.text = nil;
        borrowBuyLabel.text = @"";
        UIImage *cellBackground = [UIImage imageNamed:@"Tableemptybackground@2x"];
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:cellBackground]];
        
    } else {
        NSLog(@"%d\n",indexPath.row);
        NSLog(@"%d\n", [self.spurService.items count]);
        id item = [self.spurService.items objectAtIndex:indexPath.row];
        
        
        BOOL borrowVal = [[item objectForKey:@"borrow"] boolValue];
    
        NSString *name = [item objectForKey:@"name"];
        if (![name  isEqual:[NSNull null]])
        {
            if(borrowVal)
            {
                nameLabel.text  = [NSString stringWithFormat:@"You want to borrow %@\n", name];
            }
            else
            {
                nameLabel.text  = [NSString stringWithFormat:@"You want to buy %@\n", name];
            }
           
        }
        NSString *price = [item objectForKey:@"price"];
        if (![price  isEqual:[NSNull null]])
        {
            priceLabel.text  = price;
        }
        
        NSDate *now = [[NSDate alloc] init];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:MM:SS"];
        
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
            timeLabel.text =  [NSString stringWithFormat:@"%dh %dm ago\n",hours,minutes];
        else if (minutes)
            timeLabel.text =  [NSString stringWithFormat:@"%dm ago\n",minutes];
        else
            timeLabel.text =  [NSString stringWithFormat:@"Moments ago\n"];
            
        //NEED TO GET COUNT OF OFFERS
        
        //TODO XXX ZZZ Everything about this is terrible and egregious. I do not condone my actions, but my vision is getting blurry.
        
        NSPredicate * predicateOffers2 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"requestId == '%@'",[item valueForKey:@"id"] ]];

        [self.spurNumOffers refreshDataOnSuccess:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * numOffers = [NSString stringWithFormat:@"%d offers", [self.spurNumOffers.items count]];
                if (![numOffers isEqual:[NSNull null]])
                {
                    numOffersLabel.text  = numOffers;
                }
                
            });
        } :predicateOffers2];
        
        
        
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



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SpurIncomingOffersTableViewController * dvc = (SpurIncomingOffersTableViewController*)[segue destinationViewController];
    NSLog(@"The sender is %@",sender);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //Get the selected object in order to fill out the detail view
    id item = [self.spurService.items objectAtIndex:indexPath.row];
    
    NSLog(@"ITEM IS %@\n",item);
    [dvc setRequest:item];

    
}

@end

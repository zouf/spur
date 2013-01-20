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
#import "NSData+Base64.h"

#define ITEM_IMAGE 100
#define ITEM_NAME 101
#define PRICE 102
#define TIME 103
#define USER 104

@interface SpurIncomingOffersTableViewController ()
@property (nonatomic,retain) SpurService *spurService;
@end

@implementation SpurIncomingOffersTableViewController
@synthesize  request;
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
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"requestId == '%@'", [self.request objectForKey:@"id"]]];
    
    
    [self.spurService refreshDataOnSuccess:^{
        NSLog(@"Get all requests that have the user as the requestor!");
        [self.tableView reloadData];
        [refresh endRefreshing];
    } :predicate];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tablebackground@2x.png"]]];
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    
    UIImage *navigationImage = [UIImage imageNamed:@"Spur_feed@2x.png"];
    CGImageRef imageRef = CGImageCreateWithImageInRect(navigationImage.CGImage, CGRectMake(0, 0, 640, 88));
    navigationImage = [UIImage imageWithCGImage:imageRef
                                          scale:2.0
                                    orientation:UIImageOrientationUp];
    [self.navigationController.navigationBar setBackgroundImage:navigationImage forBarMetrics:UIBarMetricsDefault];
    CGImageRelease(imageRef);
    
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
    return ([ self.spurService.items count]  <= 7) ? 7 : [ self.spurService.items count];
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
    
    
    UILabel * nameLabel = (UILabel*)[cell viewWithTag:ITEM_NAME];
    UILabel * priceLabel = (UILabel*)[cell viewWithTag:PRICE];
    UILabel *timeLabel = (UILabel*)[cell viewWithTag:TIME];
    UIImageView *itemImage = (UIImageView*)[cell viewWithTag:ITEM_IMAGE];
    UILabel *userLabel = (UILabel*)[cell viewWithTag:USER];

    
    NSInteger theVal = [self.spurService.items count];

    if([self.spurService.items count] <= 7 && indexPath.row + 1> [self.spurService.items count]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        nameLabel.text = @"";
        priceLabel.text = @"";
        timeLabel.text = @"";
        itemImage.image = nil;
        userLabel.text = @"";
        UIImage *cellBackground = [UIImage imageNamed:@"Tableemptybackground@2x"];
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:cellBackground]];

    } else {
        
    
    
        
        UIImage *cellBackground = [UIImage imageNamed:@"Tablebackground@2x"];
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:cellBackground]];
        
        id item = [self.spurService.items objectAtIndex:indexPath.row];
        NSString *name = [item objectForKey:@"itemName"];
        if (![name  isEqual:[NSNull null]])
        {
            nameLabel.text  = name;
        }
        NSString *price = [item objectForKey:@"bestOffer"];
        if (![price  isEqual:[NSNull null]])
        {
            priceLabel.text  = price;
        }
        
        NSString *user = [item objectForKey:@"userName"];
        if (![user  isEqual:[NSNull null]])
        {
            userLabel.text  = user;
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
        
        NSString *imageData = [item objectForKey:@"pic"];
        
        if (![imageData  isEqual:[NSNull null]])
        {
            NSData *data = [NSData dataFromBase64String:imageData];
            UIImage *image = [UIImage imageWithData:data];
            
            itemImage.image  = image;
        }
    
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
    SpurExpandedIncomingOfferViewController * dvc = (SpurExpandedIncomingOfferViewController*)[segue destinationViewController];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //Get the selected object in order to fill out the detail view
    id item = [self.spurService.items objectAtIndex:indexPath.row];
    
    [dvc setRequest:self.request];
    [dvc setOffer:item];

    
    
}

@end

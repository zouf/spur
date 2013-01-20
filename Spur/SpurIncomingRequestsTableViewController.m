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
#import "SpurAppDelegate.h"

#define NAME_TAG 100
#define BUY_SELL 101
#define PRICE 102
#define DESCRIPTION 103
#define TIME 104

@interface SpurIncomingRequestsTableViewController ()
@property(nonatomic,retain) QuickDialogController * controller;
@property (retain, nonatomic) QEntryElement *nameEntry;
 @property (retain, nonatomic) QEntryElement *emailEntry;
 @property (retain, nonatomic) QEntryElement *phoneEntry;

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



-(void)removePopup:(id)sender
{
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:self.nameEntry.textValue forKey:@"name"];
    [pref setObject:self.emailEntry.textValue forKey:@"email"];
    [pref setObject:self.phoneEntry.textValue forKey:@"phone"];
    [pref setObject:[delegate deviceToken]  forKey:@"userid"];
    [pref synchronize];
    [self.controller dismissViewControllerAnimated:YES completion:^{

        SpurService *sc = [[SpurService alloc]initWithTable:@"User"];
        
        NSDictionary *item = @{
        @"deviceToken" :  [delegate deviceToken],
        @"name": self.nameEntry.textValue,
        @"email" :  self.emailEntry.textValue,
        @"phoneNumber" : self.phoneEntry.textValue
        };
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"deviceToken == '%@'",  [delegate deviceToken]]];
        [sc refreshDataOnSuccess:^{
            if([sc.items count] == 0)
                [sc addItem:item completion:^(NSUInteger index){
                }];
            
        } :(NSPredicate*)predicate];
        


    }];
}
- (void)viewDidLoad
{
    UIImage *navigationImage = [UIImage imageNamed:@"Spur_feed@2x.png"];
    CGImageRef imageRef = CGImageCreateWithImageInRect(navigationImage.CGImage, CGRectMake(0, 0, 320, 44));
    navigationImage = [UIImage imageWithCGImage:imageRef];
    [self.navigationController.navigationBar setBackgroundImage:navigationImage forBarMetrics:UIBarMetricsDefault];
    
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    if(![delegate getUserId])
    {
        QRootElement * root = [[QRootElement alloc]init];
        
           
        root.title = @"Please Register";
        root.grouped = YES;
        QSection *section = [[QSection alloc] init];
        self.nameEntry = [[QEntryElement alloc]initWithTitle:@"Name" Value:@"" Placeholder:@"John Doe"];
        self.emailEntry = [[QEntryElement alloc]initWithTitle:@"E-mail" Value:@"" Placeholder:@"matt@johndoe.com"];
        self.phoneEntry  = [[QEntryElement alloc]initWithTitle:@"Phone" Value:@"" Placeholder:@"555 555-5555"];
        
        [section addElement:self.nameEntry];
        [section addElement:self.emailEntry];
        [section addElement:self.phoneEntry];

        [root addSection:section];
        
        QuickDialogController *controller = [QuickDialogController controllerForRoot:root];
        self.controller = controller;
        [controller.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removePopup:)]];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
            
        }];
        
        
    }

 
    
    
    
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

    UILabel * name = (UILabel*)[cell viewWithTag:NAME_TAG];
    UILabel * buySell = (UILabel*)[cell viewWithTag:BUY_SELL];
    UILabel * price = (UILabel*)[cell viewWithTag:PRICE];
    UILabel *description = (UILabel*)[cell viewWithTag:DESCRIPTION];
    UILabel *time = (UILabel*)[cell viewWithTag:TIME];

    
    
    
    
    
    
    NSLog(@"%@\n", item);
    
    NSString *theName = [item objectForKey:@"userName"];
    BOOL borrow = [[item objectForKey:@"borrow"] boolValue];

    if (![theName  isEqual:[NSNull null]])
    {
        if(!borrow)
            name.text = [NSString stringWithFormat:@"%@ is looking to buy a ...\n", [item objectForKey:@"userName"] ];
        else
            name.text = [NSString stringWithFormat:@"%@ would like to borrow a ...\n", [item objectForKey:@"userName"] ];


    }
    NSDate *now = [[NSDate alloc] init];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* dateStringFromDatabase = [item objectForKey:@"posttime"];
    
    NSDate* dateFromString = [outputFormatter dateFromString:dateStringFromDatabase];
    NSString* a = [outputFormatter stringFromDate:now];
    NSDate* b = [outputFormatter dateFromString:a];
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:dateFromString
                                                  toDate:now options:0];
    
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
     NSString *lastUpdated = [NSString stringWithFormat:@"Last spurred on %@",
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

    [dvc setRequest:item];
    
}

@end

//
//  SpurAccepterOfferViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//


static NSString *const kVenmoAppId      = @"1223";
static NSString *const kVenmoAppSecret  = @"cRuKSVCexGy2wBK9PJAyJpZc9QP9HPsb";

#import "SpurExpandedPendingPaymentViewController.h"
#import "SpurService.h"
#import "SpurAppDelegate.h"
#import "SpurVenmoViewController.h"



#define NUM_ROWS 4
@interface SpurExpandedPendingPaymentViewController ()
@property (strong, nonatomic) SpurService *spurService;
@property (strong, nonatomic) id requestee;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SpurVenmoViewController *welcomeViewController;
@property (strong, nonatomic) VenmoClient *venmoClient;

@end

@implementation SpurExpandedPendingPaymentViewController
@synthesize confirmedOffer;
@synthesize window;
@synthesize welcomeViewController;
@synthesize venmoClient;

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
    
    NSLog(@"%@\n", [self.confirmedOffer objectForKey:@"requesteeID"]);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"deviceToken == '%@'", [self.confirmedOffer objectForKey:@"requestorID"]]];
    
    
    [self.spurService refreshDataOnSuccess:^{
        NSLog(@"Get all requests that have the user as the requestor!");
        if([self.spurService.items count] != 0 && self.spurService.items)
            self.requestee = [self.spurService.items objectAtIndex:0];
        NSLog(@"%@\n",self.requestee);
        [self.tableView reloadData];
    } :predicate];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        venmoClient = [VenmoClient clientWithAppId:kVenmoAppId secret:kVenmoAppSecret];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
        venmoClient.delegate = self;
#endif
        
      /*  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = welcomeViewController;
        [window makeKeyAndVisible];*/
        
        VenmoTransaction * venmoTransaction = [[VenmoTransaction alloc] init];
        venmoTransaction.type = VenmoTransactionTypePay;
        venmoTransaction.amount = [NSDecimalNumber decimalNumberWithString:@"6.67"];
        venmoTransaction.note = @"Penn Apps Hackathon";
        venmoTransaction.toUserHandle = @"mzoufaly@cs.princeton.edu";

        VenmoViewController *venmoViewController = [venmoClient viewControllerWithTransaction:
                                                    venmoTransaction];
        if (venmoViewController) {
            [self presentViewController:venmoViewController animated:YES completion:nil];
        }

 
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
        cell.textLabel.text = [NSString stringWithFormat:@"Call %@\n",[self.requestee objectForKey:@"phoneNumber"]];
    }
    else if (indexPath.row ==1 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"Message %@\n",[self.requestee objectForKey:@"phoneNumber"]];
    }
    else if (indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"Email %@\n",[self.requestee objectForKey:@"email"]];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"VenmoCell"];
                
        /*if (launchOptions) {
            NSURL *openURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
            if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
                return YES;
            }
        }*/
        
    }
    return cell;
}


@end

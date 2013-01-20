//
//  SpurExpandedOfferViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurExpandedIncomingOfferViewController.h"
#import "SpurAppDelegate.h"
#import "SpurService.h"
#import "NSData+Base64.h"


@interface SpurExpandedIncomingOfferViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceOffered;
@property (weak, nonatomic) IBOutlet UILabel *posttime;
@property (weak, nonatomic) IBOutlet UILabel *borrowLabel;

@property (nonatomic,retain) SpurService *spurService;
@property (nonatomic,retain) SpurService *spurServiceAccept;

@end

@implementation SpurExpandedIncomingOfferViewController
@synthesize offer;
@synthesize request;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}






-(void)dismissKeyboard {
    // [self.bestOffer resignFirstResponder];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ZZZ Change for each view
    self.spurService  = [[SpurService alloc]initWithTable:@"ItemOffer"];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    
    // Create a predicate that finds items where complete is false
    
    
    NSLog(@"%@\n",[self.offer objectForKey:@"itemName"]);
    NSString *name = [self.offer objectForKey:@"userName"];
    if (![name  isEqual:[NSNull null]])
    {
        self.userLabel.text  = name;
    }
    NSString *price = [self.offer objectForKey:@"bestOffer"];
    if (![price  isEqual:[NSNull null]])
    {
        self.priceOffered.text  = price;
    }
    NSString *posttime = [self.offer objectForKey:@"posttime"];
    
    
    NSDate *now = [[NSDate alloc] init];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* dateStringFromDatabase = [self.offer objectForKey:@"posttime"];
    
    NSDate* dateFromString = [outputFormatter dateFromString:dateStringFromDatabase];
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:dateFromString
                                                  toDate:now options:0];
    int hours = [components hour];
    int minutes = [components minute];
    if(hours)
        self.posttime.text =  [NSString stringWithFormat:@"%dh %dm ago\n",hours,minutes];
    else if (minutes)
        self.posttime.text =  [NSString stringWithFormat:@"%dm ago\n",minutes];
    else
        self.posttime.text =  [NSString stringWithFormat:@"Moments ago\n"];
    

    
   
    
    NSString *itemlabel = [self.offer objectForKey:@"itemName"];
    
    if (![itemlabel isEqual:[NSNull null]])
    {
        self.itemLabel.text  = itemlabel;
    }
    
    NSString *borrow = [self.offer objectForKey:@"borrow"];
    
    if (![borrow  isEqual:[NSNull null]])
    {
        self.borrowLabel.text  = borrow;
    }
    
    NSString *imageData = [self.offer objectForKey:@"pic"];
    
    if (![imageData  isEqual:[NSNull null]])
    {
        NSData *data = [NSData dataFromBase64String:imageData];
        UIImage *image = [UIImage imageWithData:data];
        
        self.itemImageView.image  = image;
    }
    
    
    
	// Do any additional setup after loading the view.
}


-(void)sendOfferToServer
{
    
    NSLog(@"Accept the offer and notify the user!!\n");
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //Get the string date
    
    NSString* str = [formatter stringFromDate:date];
    
    
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    //ZZZ Model for ItemAccepted
    NSLog(@"%@\n", offer);
    NSDictionary *item = @{
    @"requestId" :  [self.request objectForKey:@"id"],
    @"bestOffer" :  [offer objectForKey:@"id"],
    @"posttime": str,
    @"itemName": [self.request objectForKey:@"name"],
    @"requestorName": [[NSUserDefaults standardUserDefaults]objectForKey:@"name"],
    @"requesteeName": [offer objectForKey:@"userName"],

    @"requestorID": [delegate getUserId],
    @"requesteeID": [offer objectForKey:@"userId"]
    };
    NSLog(@"%@\n",item);
    [self.spurServiceAccept addItem:item completion:^(NSUInteger index){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Thanks" message:@"You've accepted the offer." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    [self.spurService acceptPayment:self.offer completion:^(NSUInteger index){
        NSLog(@"Updated");
    }];
    
    
}

- (IBAction)acceptOffer:(id)sender {
    self.spurServiceAccept  = [[SpurService alloc]initWithTable:@"ItemAccepted"];
    
    
    // If user is already logged in, no need to ask for auth
    [self sendOfferToServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

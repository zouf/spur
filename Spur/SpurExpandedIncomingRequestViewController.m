//
//  SpurExpandedRequestViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurExpandedIncomingRequestViewController.h"
#import "SpurAppDelegate.h"
#import "SpurService.h"
#import "NSData+Base64.h"

@interface SpurExpandedIncomingRequestViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *borrowLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedLabel;
@property (nonatomic,retain) SpurService * spurService;
@property (nonatomic,retain) SpurService * spurServiceOffer;



@property (weak, nonatomic) IBOutlet UITextField *bestOffer;
@end

@implementation SpurExpandedIncomingRequestViewController
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
    [self.bestOffer resignFirstResponder];
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.spurService  = [[SpurService alloc]initWithTable:@"itemrequest"];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    

        id item = self.request;
        
        NSLog(@"%@\n",[item objectForKey:@"name"]);
        NSString *name = [item objectForKey:@"userName"];
        if (![name  isEqual:[NSNull null]])
        {
            self.userLabel.text  = name;
        }
        NSString *price = [item objectForKey:@"price"];
        if (![price  isEqual:[NSNull null]])
        {
            self.priceLabel.text  = price;
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
        self.postedLabel.text =  [NSString stringWithFormat:@"%dh %dm ago\n",hours,minutes];
    else if (minutes)
        self.postedLabel.text =  [NSString stringWithFormat:@"%dm ago\n",minutes];
    else
        self.postedLabel.text =  [NSString stringWithFormat:@"Moments ago\n"];
    

    
    
    
        NSString *itemlabel = [item objectForKey:@"name"];
    
        if (![itemlabel isEqual:[NSNull null]])
        {
            self.itemLabel.text  = itemlabel;
        }
  
        BOOL borrowVal = [[item objectForKey:@"borrow"] boolValue];
    
        if(borrowVal)
        {
            self.borrowLabel.text = @"Borrow";
            
        }
        else
        {
            self.borrowLabel.text = @"Buy!";
        }



	// Do any additional setup after loading the view.
}


-(void)sendOfferToServer
{
    
    NSLog(@"Insert into offers table!\n");
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //Get the string date
    
    NSString* str = [formatter stringFromDate:date];
    
    //Encode the image
    NSData *data = nil;
    NSString *imageData = @"";
    if (self.itemImage != nil) {
        UIImage *image = self.itemImage;
        data = UIImageJPEGRepresentation(image, 0.05f);
        imageData = [data base64EncodedString];
    }
    
    
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"%@\n",self.itemLabel.text);
    // ZZZ model for item Offer
    NSDictionary *item = @{
    @"requestId" :  [self.request objectForKey:@"id"],
    @"bestOffer" :  self.bestOffer.text,
    @"deviceToken" : delegate.deviceToken,
    @"posttime": str,
    @"itemName": self.itemLabel.text,
//    @"borrow": self.borrowLabel.text,
    @"requestorName": [self.request objectForKey:@"userName"],
    @"requestorId": [self.request objectForKey:@"userId"],
    @"accepted": @(NO),
    @"userId": [delegate getUserId],
    @"userName": [[NSUserDefaults standardUserDefaults]objectForKey:@"name"],
    @"pic": imageData
    };
    NSLog(@"%@\n",self.request);

    [self.spurServiceOffer addItem:item completion:^(NSUInteger index){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Thanks" message:@"Your offer's been placed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}
- (void) login
{
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    UINavigationController *controller =
    [self.spurServiceOffer.client
     loginViewControllerWithProvider:@"google"
     completion:^(MSUser *user, NSError *error) {
         
         
         if (error) {
             NSLog(@"Authentication Error: %@", error);
             // Note that error.code == -1503 indicates
             // that the user cancelled the dialog
         } else {
             // No error, so load the data
             [self.spurServiceOffer refreshDataOnSuccess:^{
                 NSLog(@"Rock on!\n");
                 [delegate setUserId:self.spurServiceOffer.client.currentUser.userId];
                 [self sendOfferToServer];
             }];
         }
         
         
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)submitOffer:(id)sender {
    self.spurServiceOffer  = [[SpurService alloc]initWithTable:@"itemoffer"];

    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

    // If user is already logged in, no need to ask for auth
    if ([delegate getUserId] == nil)
    {
        // We want the login view to be presented after the this run loop has completed
        // Here we use a delay to ensure this.
        [self performSelector:@selector(login) withObject:self afterDelay:0.1];
    }
    else
    
    {
        [self sendOfferToServer];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *myPicker = [[UIImagePickerController alloc] init];
    [myPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [myPicker setDelegate:self];
    
    [self.navigationController presentViewController:myPicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.itemImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.itemImageView setImage:self.itemImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
        
    
    
}

@end

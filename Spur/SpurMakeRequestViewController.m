//
//  SpurMakeRequestViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurMakeRequestViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "SpurService.h"
#import "SpurAppDelegate.h"
#import "QuickDialog.h"

@interface SpurMakeRequestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *borrowField;
@property (weak, nonatomic) IBOutlet UITextField *priceField;
/*@property (retain, nonatomic) QEntryElement *nameEntry;
@property (retain, nonatomic) QEntryElement *priceEntry;
@property (retain, nonatomic) QBooleanElement *borrow;
*/
@property (strong, nonatomic) SpurService *spurService;


@end

@implementation SpurMakeRequestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
  //      self.root = [[QRootElement alloc] init];
    }
    
    return self;
}


// mzoufaly add the following in order to enforce login
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

-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
    [self.priceField resignFirstResponder];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.spurService  = [[SpurService alloc]initWithTable:@"itemrequest"];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    /*
    self.root = [[QRootElement alloc]init];

    self.quickDialogTableView = [[QuickDialogTableView alloc]
                                 initWithController:self];
    self.view = self.quickDialogTableView;
    self.quickDialogTableView setStyleProvider:<#(NSObject<QuickDialogStyleProvider> *)#>
    
    
    self.root.title = @"Request an Item";
    self.root.grouped = YES;
    QSection *section = [[QSection alloc] init];
    self.nameEntry = [[QEntryElement alloc]initWithTitle:@"What is it?" Value:@"" Placeholder:@"iPhone charger"];
    self.priceEntry = [[QEntryElement alloc]initWithTitle:@"How Much?" Value:@"" Placeholder:@"cup of coffee or $2"];
    
    self.borrow = [[QBooleanElement alloc]initWithTitle:@"Buy it (or just borrow)?" BoolValue:NO];
    
    [section addElement:self.nameEntry];
    [section addElement:self.priceEntry];
    [section addElement:self.borrow];
    [self.root addSection:section];*/


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)makeRequest:(id)sender {
    NSLog(@"Insert into requests table!\n");
    
    NSDate* date = [NSDate date];
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
    
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:MM:SS"];
    
    //Get the string date
    
    NSString* str = [formatter stringFromDate:date];
    
    
    SpurAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *nm = [delegate getUserId];
    BOOL borrow = NO;
    if (self.borrowField.selectedSegmentIndex == 1)
        borrow = YES;
    // model for item requested
    NSDictionary *item = @{
    @"name" : self.nameField.text,
    @"price": self.priceField.text,
    @"deviceToken" : delegate.deviceToken,
    @"posttime": str,
     @"userId": nm,
    @"userName": [[NSUserDefaults standardUserDefaults]objectForKey:@"name"],
    @"borrow": @(borrow)
    };
    [self.spurService addItem:item completion:^(NSUInteger index){
        NSLog(@"Done!?\n");
        
    }];

}


@end

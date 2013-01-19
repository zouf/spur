//
//  SpurSignUpViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurSignUpViewController.h"

@interface SpurSignUpViewController ()

@end

@implementation SpurSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dismissKeyboard {
    [self.nameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.phoneField resignFirstResponder];


}
- (IBAction)savePreferences:(id)sender {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:self.nameField.text forKey:@"name"];
    [pref setObject:self.emailField.text forKey:@"email"];
    [pref setObject:self.phoneField.text forKey:@"phone"];
    [self dismissKeyboard];

    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Saved" message:@"Preferences Saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
    return;

}

- (void)loadPreferences {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    if([pref stringForKey:@"name"])
        self.nameField.text = [pref objectForKey:@"name"];
    if([pref stringForKey:@"email"])
        self.emailField.text = [pref objectForKey:@"email"];
    if([pref stringForKey:@"phone"])
        self.phoneField.text = [pref objectForKey:@"phone"];
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self loadPreferences];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

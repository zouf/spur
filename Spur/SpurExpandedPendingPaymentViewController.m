//
//  SpurAccepterOfferViewController.m
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurExpandedPendingPaymentViewController.h"

@interface SpurExpandedPendingPaymentViewController ()

@end

@implementation SpurExpandedPendingPaymentViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0,0,320,100)];
        UILabel * lbl = [[UILabel alloc]initWithFrame:CGRectMake(0,50,50,50)];
        lbl.text = @"Actions to take for the transaction";
        [v addSubview:lbl];
    }
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
    else
    {
        NSLog(@"Sel 2");

    }
}



@end

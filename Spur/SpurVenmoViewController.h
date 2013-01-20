//
//  SpurVenmoViewController.h
//  Spur
//
//  Created by Matthew Zoufaly on 1/19/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpurVenmoViewController : UIViewController

@property (strong, nonatomic) VenmoClient *venmoClient;
@property (strong, nonatomic) VenmoTransaction *venmoTransaction;

@end
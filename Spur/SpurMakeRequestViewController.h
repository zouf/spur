//
//  SpurMakeRequestViewController.h
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialog.h"

@interface SpurMakeRequestViewController : UIViewController
- (void) login;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitRequest;
@end

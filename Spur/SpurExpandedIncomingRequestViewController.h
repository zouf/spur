//
//  SpurExpandedRequestViewController.h
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpurExpandedIncomingRequestViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic,retain) id request;
- (IBAction)takePicture:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *itemImageView;
@property (strong, nonatomic) UIImage *itemImage;

@end

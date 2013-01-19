//
//  SpurAppDelegate.h
//  Spur
//
//  Created by Mike Verderese on 1/18/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog/QuickDialog.h>



@interface SpurAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSString *deviceToken;

@property (strong, nonatomic) UIWindow *window;

-(NSString *)getUserId;
-(void)setUserId:(NSString*)theID;

@end

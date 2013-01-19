//
//  SpurService.h
//  Spur
//
//  Created by Matthew Zoufaly on 1/19/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

#pragma mark * Block Definitions


typedef void (^CompletionBlock) ();
typedef void (^CompletionWithIndexBlock) (NSUInteger index);
typedef void (^BusyUpdateBlock) (BOOL busy);


#pragma mark * SpurService public interface




@interface SpurService : NSObject<MSFilter>

// Declare the singleton instance for other users
+ (SpurService *) getCurrent;


// Declare method to register device token for other users
- (void) registerDeviceToken:(NSString *)deviceToken;

@property (nonatomic, strong)   NSArray *items;
@property (nonatomic, strong)   MSClient *client;
@property (nonatomic, copy)     BusyUpdateBlock busyUpdate;

- (void) refreshDataOnSuccess:(CompletionBlock) completion;
- (void) refreshDataOnSuccess:(CompletionBlock)completion :(NSPredicate*)predicate;

- (void) addItem:(NSDictionary *) item
      completion:(CompletionWithIndexBlock) completion;

- (void) acceptPayment: (NSDictionary *) item
           completion:(CompletionWithIndexBlock) completion;


- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse;

-(SpurService *) initWithTable:(NSString*)named;






@end

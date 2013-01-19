//
//  SpurService.m
//  Spur
//
//  Created by Matthew Zoufaly on 1/19/13.
//  Copyright (c) 2013 Mike Verderese. All rights reserved.
//

#import "SpurService.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


#pragma mark * Private interace


@interface SpurService()

@property (nonatomic, strong)   MSTable *table;
@property (nonatomic)           NSInteger busyCount;

@end


#pragma mark * Implementation


@implementation SpurService

@synthesize items;

// Add a variable to support Singleton creation.
SpurService *instance;


// Add static method to return TodoService instance.
+ (SpurService *)getCurrent
{
    if (instance == nil) {
        instance = [[SpurService alloc] init];
    }
    return instance;
}



// Instance method to register deviceToken in Devices table.
// Called in AppDelegate.m when APNS registration succeeds.
- (void)registerDeviceToken:(NSString *)deviceToken
{
    MSTable* devicesTable = [self.client getTable:@"Devices"];
    NSDictionary *device = @{ @"deviceToken" : deviceToken };
    
    
    // Insert the item into the devices table and add to the items array on completion
    [devicesTable insert:device completion:^(NSDictionary *result, NSError *error) {
        if (error) {
            NSLog(@"ERROR %@", error);
        }
    }];
    
    
}

-(SpurService *) initWithTable:(NSString*)named
{
    // Initialize the Mobile Service client with your URL and key
    MSClient *newClient = [MSClient clientWithApplicationURLString:@"https://spurmobile.azure-mobile.net/"
                                                withApplicationKey:@"DakthyzRTUISjPLyzrlEAAYLixozDx13"];
    
    // Add a Mobile Service filter to enable the busy indicator
    self.client = [newClient clientwithFilter:self];
    
    
    // Create an MSTable instance to allow us to work with the TodoItem table
    self.table = [_client getTable:named];
    
    self.items = [[NSMutableArray alloc] init];
    self.busyCount = 0;
    
    return self;
}

- (void) refreshDataOnSuccess:(CompletionBlock)completion
{
    
    // Query the TodoItem table and update the items property with the results from the service
    [self.table readWhere:nil completion:^(NSArray *results, NSInteger totalCount, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        items = [results mutableCopy];
        
        // Let the caller know that we finished
        completion();
    }];
    
}

- (void) refreshDataOnSuccess:(CompletionBlock)completion :(NSPredicate*)predicate
{
    
    // Query the TodoItem table and update the items property with the results from the service
    [self.table readWhere:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        items = [results mutableCopy];
        
        // Let the caller know that we finished
        completion();
    }];
    
}



-(void) addItem:(NSDictionary *)item completion:(CompletionWithIndexBlock)completion
{
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        NSUInteger index = [items count];
        [(NSMutableArray *)items insertObject:result atIndex:index];
        
        // Let the caller know that we finished
        completion(index);
    }];
}

-(void) completeItem:(NSDictionary *)item completion:(CompletionWithIndexBlock)completion
{
    // Cast the public items property to the mutable type (it was created as mutable)
    NSMutableArray *mutableItems = (NSMutableArray *) items;
    
    // Set the item to be complete (we need a mutable copy)
    NSMutableDictionary *mutable = [item mutableCopy];
    [mutable setObject:@(YES) forKey:@"complete"];
    
    // Replace the original in the items array
    NSUInteger index = [items indexOfObjectIdenticalTo:item];
    [mutableItems replaceObjectAtIndex:index withObject:mutable];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.table update:mutable completion:^(NSDictionary *item, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        NSUInteger index = [items indexOfObjectIdenticalTo:mutable];
        [mutableItems removeObjectAtIndex:index];
        
        // Let the caller know that we have finished
        completion(index);
    }];
}

- (void) busy:(BOOL) busy
{
    // assumes always executes on UI thread
    if (busy) {
        if (self.busyCount == 0 && self.busyUpdate != nil) {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil) {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}


#pragma mark * MSFilter methods


- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self busy:NO];
        onResponse(response, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    onNext(request, wrappedResponse);
}

@end

//
//  ViewController.m
//  RestKitCrash
//
//  Created by Paul Melnikow on 7/13/13.
//  Copyright (c) 2013 Midstate Spring. All rights reserved.
//

#import "ViewController.h"
#import "Parent.h"
#import "Child.h"
#import <RestKit/RestKit.h>

@interface ViewController ()

@property (retain) RKObjectManager *manager;

@end

@implementation ViewController


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _setUpManager];
        [self _setUpMappings];
    }
    return self;
}


- (void) _setUpManager {
    NSError *error = nil;
    
    self.manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:12345"]];
    self.manager.requestSerializationMIMEType = @"application/json";
    
    [RKObjectManager setSharedManager:self.manager];
    
    [self.manager.HTTPClient setAuthorizationHeaderWithUsername:@"testuser" password:@"testpassword"];
    
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *store = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    if (!RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error))
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
    if (![store addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error])
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    
    [store createManagedObjectContexts];
    self.manager.managedObjectStore = store;    
}


- (void) _setUpMappings {
    RKEntityMapping *entityMapping =
    [RKEntityMapping mappingForEntityForName:@"Parent" inManagedObjectStore:self.manager.managedObjectStore];
    
    RKEntityMapping *childEntityMapping =
    [RKEntityMapping mappingForEntityForName:@"Child" inManagedObjectStore:self.manager.managedObjectStore];
    [childEntityMapping addAttributeMappingsFromArray:@[@"name"]];
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"children"
                                                                                  toKeyPath:@"children"
                                                                                withMapping:childEntityMapping]];
    
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                 method:RKRequestMethodPUT
                                            pathPattern:@"/crashtest"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.manager addResponseDescriptor:responseDescriptor];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[entityMapping inverseMapping]
                                                                                   objectClass:[Parent class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPUT];
    [self.manager addRequestDescriptor:requestDescriptor];
}


- (IBAction) createObject:(id) sender {
    NSManagedObjectContext *context = self.manager.managedObjectStore.mainQueueManagedObjectContext;
    
    NSEntityDescription *parentEntity = [NSEntityDescription entityForName:NSStringFromClass([Parent class])
                                                    inManagedObjectContext:context];
    Parent *parent = [[Parent alloc] initWithEntity:parentEntity insertIntoManagedObjectContext:context];
    
    NSEntityDescription *childEntity = [NSEntityDescription entityForName:NSStringFromClass([Child class])
                                                   inManagedObjectContext:context];
    Child *child = [[Child alloc] initWithEntity:childEntity insertIntoManagedObjectContext:context];
    child.name = @"Ricky";
    [parent addChildrenObject:child];
    
    NSError *error = nil;
   
#if 1
    
    // Crashes
    
    if (![self.manager.managedObjectStore.mainQueueManagedObjectContext save:&error]) {
        NSLog(@"Error saving store: %@", error);
        return;
    }
    
#elif 0
    
    // Does not crash
    
    if (![self.manager.managedObjectStore.mainQueueManagedObjectContext save:&error]) {
        NSLog(@"Error saving store: %@", error);
        return;
    }
    
    if (![self.manager.managedObjectStore.persistentStoreManagedObjectContext save:&error]) {
        NSLog(@"Error saving store: %@", error);
        return;
    }
    
#elif 0
    
    // Does not crash
    
    if (![self.manager.managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&error]) {
        NSLog(@"Error saving store: %@", error);
        return;
    }
    
#endif
    
    [self.manager putObject:parent
                       path:@"/crashtest"
                 parameters:nil
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         NSLog(@"success");
     } failure:^(RKObjectRequestOperation *operation, NSError *error) {
         // Probably there's no server, or the server doesn't have the expected response
         NSLog(@"error: %@", error);
     }];
}


@end

//
//  Parent.h
//  RestKitCrash
//
//  Created by Paul Melnikow on 7/13/13.
//  Copyright (c) 2013 Midstate Spring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Parent : NSManagedObject

@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *children;
@end

@interface Parent (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(NSManagedObject *)value;
- (void)removeChildrenObject:(NSManagedObject *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end

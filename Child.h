//
//  Child.h
//  RestKitCrash
//
//  Created by Paul Melnikow on 7/13/13.
//  Copyright (c) 2013 Midstate Spring. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Parent;

@interface Child : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Parent *parent;

@end

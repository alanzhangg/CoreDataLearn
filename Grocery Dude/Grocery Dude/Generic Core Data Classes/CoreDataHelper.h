//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/5.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext * context;
@property (nonatomic, readonly) NSManagedObjectModel * model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator * coordinator;
@property (nonatomic, readonly) NSPersistentStore * store;

- (void)setupCoreData;
- (void)saveContext;

@end

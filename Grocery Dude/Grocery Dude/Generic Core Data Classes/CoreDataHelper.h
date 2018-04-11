//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/5.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MigrationVC.h"

@interface CoreDataHelper : NSObject<UIAlertViewDelegate, NSXMLParserDelegate>

@property (nonatomic, readonly) NSManagedObjectContext * context;
@property (nonatomic, readonly) NSManagedObjectModel * model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator * coordinator;
@property (nonatomic, readonly) NSPersistentStore * store;
@property (nonatomic, strong) MigrationVC * migrationVC;
@property (nonatomic, strong) UIAlertView * importAlertView;
@property (nonatomic, strong) NSXMLParser * parser;
@property (nonatomic, readonly) NSManagedObjectContext * importContext;

@property (nonatomic, readonly) NSManagedObjectContext * sourceContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator * sourceCoordinator;
@property (nonatomic, readonly) NSPersistentStore * sourceStore;

@property (nonatomic, readonly) NSManagedObjectContext * parentContext;

@property (nonatomic, strong) NSTimer * importTimer;


- (void)setupCoreData;
- (void)saveContext;
- (void)backgroundSaveContext;

@end

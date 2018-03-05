//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/5.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES
NSString * storeFileName = @"Grocery-Dude.sqlite";

#pragma mark - PATHS

- (NSString *)applicationDocumentsDirectory{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoreDirection{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSURL * storeDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Store"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[storeDirectory path]]) {
        NSError * error = nil;
        if ([fileManager createDirectoryAtURL:storeDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (debug == 1) {
                NSLog(@"Successfully");
            }else
                NSLog(@"Failed");
        }
    }
    
    return storeDirectory;
}

- (NSURL *)storeURL{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoreDirection] URLByAppendingPathComponent:storeFileName];
}

#pragma mark - SETUP

- (instancetype)init{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {
        return nil;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    return self;
}

- (void)loadStore{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    NSError * error = nil;
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
    if (!_store) {
        NSLog(@"Fail");
        abort();
    }else{
        if (debug == 1) {
            NSLog(@"Successfully %@", _store);
        }
    }
}

- (void)setupCoreData{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self loadStore];
}

#pragma mark - SAVING

- (void)saveContext{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError * error = nil;
        if ([_context save:&error]) {
            NSLog(@"save");
        }else{
            NSLog(@"Failed");
        }
    }else
        NSLog(@"Skipped");
}



@end

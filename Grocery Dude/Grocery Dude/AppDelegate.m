//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/5.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "AppDelegate.h"
#import "Item+CoreDataClass.h"
#import "Unit+CoreDataClass.h"

#define debug 1

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     [[self chd] saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self chd];
    [self demo];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[self chd] saveContext];
}

- (void)demo{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
//    [self showUnitAndItemCount];
//    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"name == %@", @"Kg"];
//    [request setPredicate:filter];
//    NSAsynchronousFetchResult * fetchResut = [[[self chd] context] executeRequest:request error:nil];
//    for (Unit * unit in fetchResut.finalResult) {
//        [_coreDataHelper.context deleteObject:unit];
//        NSLog(@"A Kg unit object was deleted");
//    }
//    NSLog(@"After deletion of the unit entity:");
//    [self showUnitAndItemCount];
//    [[self chd] saveContext];
    
//    Unit * kg = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:[[self chd] context]];
//    Item * oranges = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[[self chd] context]];
//    Item * bananas = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[[self chd] context]];
//    kg.name = @"Kg";
//    oranges.name = @"Oranges";
//    bananas.name = @"Bananas";
//    oranges.quantity = @1;
//    bananas.quantity = @4;
//    oranges.listed = @YES;
//    bananas.listed = @YES;
//    oranges.unit = kg;
//    bananas.unit = kg;
//
//    NSLog(@"Inserted %@", oranges.name);
//    NSLog(@"Inserted %@", bananas.name);
//    [[self chd] saveContext];
    
//    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    [request setFetchLimit:50];
//    NSError * error = nil;
//    NSAsynchronousFetchResult * result = [_coreDataHelper.context executeRequest:request
//                                      error:&error];
//    if (error) {
//        NSLog(@"%@", error);
//    }else{
//        for (Unit * unit in result.finalResult) {
//            NSLog(@"Fetched object = %@", unit.name);
//        }
//    }
    
//    for (int i = 0; i < 50000; i++) {
//        Measurement * newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:[_coreDataHelper context]];
//        newMeasurement.abs = [NSString stringWithFormat:@"--->> LOTS OF TEST DATA x%i", i];
//        NSLog(@"Inserted %@", newMeasurement.abs);
//    }
//    [_coreDataHelper saveContext];
    
//    NSArray * newItemNames = @[@"Apples", @"Bread", @"Cheese", @"Sausages", @"Butter", @"Orange Juices", @"Cereal", @"",];
//    for (NSString * newItemName in newItemNames) {
//        Item * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_coreDataHelper.context];
//        newItem.name = newItemName;
//        NSLog(@"Inserted New Managed Object for '%@'", newItem.name);
//    }
    
//    NSFetchRequest * request = [[_coreDataHelper model] fetchRequestTemplateForName:@"Test"];
    
//    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
//    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    [request setSortDescriptors:@[sort]];
//
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"name != %@", @"Coffee"];
//    [request setPredicate:filter];
//
//    NSAsynchronousFetchResult * fetchObject = [_coreDataHelper.context executeRequest:request error:nil];
//    for (Item * item in fetchObject.finalResult) {
//        NSLog(@"Fetched Object = %@", item.name);
//    }
}

- (void)showUnitAndItemCount{
    NSFetchRequest * items = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError * itemsError = nil;
    NSAsynchronousFetchResult * result = [[[self chd] context] executeRequest:items error:&itemsError];
    if (itemsError) {
        NSLog(@"%@", itemsError);
    }else{
        NSLog(@"Found %lu item(s)", (unsigned long)[result finalResult].count);
    }
    
    NSFetchRequest * units = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError * unitsError = nil;
    NSAsynchronousFetchResult * unitResult = [[[self chd] context] executeRequest:units error:&unitsError];
    if (unitsError) {
        NSLog(@"%@", unitsError);
    }else{
        NSLog(@"Found %lu unit(s)", (unsigned long)[unitResult finalResult].count);
    }
    
}

- (CoreDataHelper *)chd{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _coreDataHelper = [CoreDataHelper new];
        });
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}


@end

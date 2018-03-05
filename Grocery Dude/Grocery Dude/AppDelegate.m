//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/5.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "AppDelegate.h"
#import "Item+CoreDataClass.h"

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
    NSArray * newItemNames = @[@"Apples", @"Bread", @"Cheese", @"Sausages", @"Butter", @"Orange Juices", @"Cereal", @"",];
    for (NSString * newItemName in newItemNames) {
        Item * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_coreDataHelper.context];
        newItem.name = newItemName;
        NSLog(@"Inserted New Managed Object for '%@'", newItem.name);
    }
}

- (CoreDataHelper *)chd{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}


@end

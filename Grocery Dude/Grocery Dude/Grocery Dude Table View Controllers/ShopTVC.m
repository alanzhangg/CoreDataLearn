//
//  ShopTVC.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/21.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "ShopTVC.h"
#import "AppDelegate.h"
#import "Item+CoreDataClass.h"
#import "Unit+CoreDataClass.h"
#import "ItemVC.h"

@interface ShopTVC ()

@end

@implementation ShopTVC

#define debug 1

- (void)viewDidLoad {
    [super viewDidLoad];
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    static NSString * cellIdentifier = @"Shop Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Item * item = [self.frc objectAtIndexPath:indexPath];
    NSMutableString * title = [NSMutableString stringWithFormat:@"%@%@ %@", item.quantity, item.unit.name, item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, title.length)];
    cell.textLabel.text = title;
    if (item.collected.boolValue) {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [cell.textLabel setTextColor:
         [UIColor colorWithRed:0.36 green:0.74 blue:0.34 alpha:1.0]
         ];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18]];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    cell.imageView.image = [UIImage imageWithData:item.thumbnail];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Item * item = [self.frc objectAtIndexPath:indexPath];
    if (item.collected.boolValue) {
        item.collected = @NO;
    }else{
        item.collected = @YES;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    ItemVC * itemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemVC"];
    itemVC.selectedItemID = [[self.frc objectAtIndexPath:indexPath] objectID];
    [self.navigationController pushViewController:itemVC animated:YES];
}

#pragma mark - INTERACTION

- (IBAction)clear:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([self.frc.fetchedObjects count] == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Clear" message:@"Add items using the Prepare tab" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    BOOL nothingCleared = YES;
    for (Item * item in self.frc.fetchedObjects) {
        if (item.collected.boolValue) {
            item.listed = @NO;
            item.collected = @NO;
            nothingCleared = NO;
        }
    }
    if (nothingCleared) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Select items to be removed from the list" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - DATA

- (void)configureFetch{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    NSFetchRequest * request = [[cdh.model fetchRequestTemplateForName:@"ShoppingList"] copy];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"locationAtShop.aisle" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                ];
    [request setFetchBatchSize:20];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtShop.aisle" cacheName:nil];
    self.frc.delegate = self;
}

@end

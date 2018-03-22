//
//  PrepareTVC.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/9.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "PrepareTVC.h"
#import "CoreDataHelper.h"
#import "Item+CoreDataClass.h"
#import "Unit+CoreDataClass.h"
#import "AppDelegate.h"
#import "ItemVC.h"

@interface PrepareTVC ()

@end

@implementation PrepareTVC

#define debug 1

- (void)viewDidLoad {
    [super viewDidLoad];
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self configureFetch];
    [self performFetch];
    self.clearConfirmActionSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preformFetch) name:@"SomethingChanged" object:nil];
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
    static NSString * cellIdentifier = @"Item Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    Item * item = [self.frc objectAtIndexPath:indexPath];
    NSMutableString * title = [NSMutableString stringWithFormat:@"%@%@ %@", item.quantity, item.unit.name, item.name];
//    NSLog(@"%@", item.locationAtHome.storedIn);
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, title.length)];
    cell.textLabel.text = title;
    if ([item.listed boolValue]) {
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:18]];
        [cell.textLabel setTextColor:[UIColor orangeColor]];
    }else{
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
    }
    return cell;
}

//- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
//    if (debug == 1) {
//        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
//    }
//    return nil;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item * deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSManagedObjectID * itemid = [[self.frc objectAtIndexPath:indexPath] objectID];
    Item * item = (Item *)[self.frc.managedObjectContext existingObjectWithID:itemid error:nil];
    if ([item.listed boolValue]) {
        item.listed = @NO;
    }else{
        item.listed = @YES;
        item.collected = @NO;
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
    CoreDataHelper* cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    NSFetchRequest * request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSAsynchronousFetchResult * result = [cdh.context executeRequest:request error:nil];
    NSArray * shoppingList = result.finalResult;
    if (shoppingList.count > 0) {
        self.clearConfirmActionSheet = [[UIActionSheet alloc] initWithTitle:@"Clear Entire Shopping List?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles:nil];
        [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Clear" message:@"Add items ro the shop Tab" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    shoppingList = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (actionSheet == self.clearConfirmActionSheet) {
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            [self performSelector:@selector(clearList)];
        }else if (buttonIndex == [actionSheet cancelButtonIndex]){
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
        }
    }
}

- (void)clearList{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    NSFetchRequest * request = [cdh.model fetchRequestTemplateForName:@"ShoppingList"];
    NSAsynchronousFetchResult * result = [cdh.context executeRequest:request error:nil];
    NSArray * shoppingList = result.finalResult;
    for (Item * item  in shoppingList) {
        item.listed = @NO;
    }
}

#pragma mark - DATA

- (void)configureFetch{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[UIApplication sharedApplication].delegate chd];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"locationAtHome.storedIn" ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    
    [request setFetchBatchSize:50];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:@"locationAtHome.storedIn" cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - SEGUE

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    ItemVC * itemVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Item Segue"]) {
        CoreDataHelper * cdh = [(AppDelegate *)[UIApplication sharedApplication].delegate chd];
        Item * newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
        NSError * error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:@[newItem] error:&error]) {
            NSLog(@"Couldn't obtain a permanent ID for Object %@", error);
        }
        itemVC.selectedItemID = newItem.objectID;
    }else{
        NSLog(@"Unidentified Segue Attempted!");
    }
}

@end

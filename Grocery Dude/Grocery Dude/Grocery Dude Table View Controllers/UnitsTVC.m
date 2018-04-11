//
//  UnitsTVC.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/26.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "UnitsTVC.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Unit+CoreDataClass.h"
#import "UnitVC.h"

@interface UnitsTVC ()

@end

@implementation UnitsTVC

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

#pragma mark - SEGUE

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UnitVC * unitVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Object Segue"]) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Unit * newUnit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
        NSError * error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:@[newUnit] error:&error]) {
            NSLog(@"Couldn't obtain a permanent ID for Object %@", error);
        }
        unitVC.selectedObjectID = newUnit.objectID;
    }else if ([segue.identifier isEqualToString:@"Edit Object Segue"]){
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        unitVC.selectedObjectID = [[self.frc objectAtIndexPath:indexPath] objectID];
    }else{
        NSLog(@"Unidentified Segue Attempted");
    }
}

#pragma mark - TABLEVIEW DELEGATE

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    static NSString * cellIndentifier = @"Unit Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    Unit * unit = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = unit.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Unit * deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -DATA

- (void)configureFetch{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                ];
    [request setFetchBatchSize:20];
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:cdh.context sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - INTERACTION

- (IBAction)done:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


@end

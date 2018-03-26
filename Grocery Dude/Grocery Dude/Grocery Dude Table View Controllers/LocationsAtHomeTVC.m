//
//  LocationsAtHomeTVC.m
//  Grocery Dude
//
//  Created by Tim Roadley on 24/12/12.
//  Copyright (c) 2012 Tim Roadley. All rights reserved.
//

#import "LocationsAtHomeTVC.h"
#import "LocationAtHomeVC.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtHome+CoreDataClass.h"

@implementation LocationsAtHomeTVC
#define debug 1

#pragma mark - DATA
- (void)configureFetch {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"storedIn" ascending:YES],nil];
    [request setFetchBatchSize:50];
    self.frc =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:cdh.context
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.frc.delegate = self;
}

#pragma mark - VIEW
- (void)viewDidLoad {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    // Respond to changes in underlying store
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    static NSString *cellIdentifier = @"LocationAtHome Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    LocationAtHome *locationAtHome = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = locationAtHome.storedIn;
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LocationAtHome *deleteTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deleteTarget];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - INTERACTION
- (IBAction)done:(id)sender {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SEGUE
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    LocationAtHomeVC *locationAtHomeVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"Add Object Segue"])
    {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        LocationAtHome *newLocationAtHome =
        [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome"
                                      inManagedObjectContext:cdh.context];
        NSError *error = nil;
        if (![cdh.context obtainPermanentIDsForObjects:[NSArray arrayWithObject:newLocationAtHome] error:&error]) {
            NSLog(@"Couldn't obtain a permanent ID for object %@", error);
        }
        locationAtHomeVC.selectedObjectID = newLocationAtHome.objectID;
    }
    else if ([segue.identifier isEqualToString:@"Edit Object Segue"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        locationAtHomeVC.selectedObjectID = [[self.frc objectAtIndexPath:indexPath] objectID];
    }
    else {
        NSLog(@"Unidentified Segue Attempted!");
    }
}

@end

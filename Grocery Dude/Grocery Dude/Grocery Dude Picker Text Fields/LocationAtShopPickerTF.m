//
//  LocationAtShopPickerTF.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/27.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "LocationAtShopPickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtShop+CoreDataClass.h"

@implementation LocationAtShopPickerTF

#define debug 1

- (void)fetch{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[UIApplication sharedApplication].delegate chd];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES];
    [request setSortDescriptors:@[sort]];
    [request setFetchBatchSize:20];
    NSError * error;
    NSAsynchronousFetchResult * result = [cdh.context executeRequest:request error:&error];
    self.pickerData = result.finalResult;
    if (error) {
        NSLog(@"Error populating picker: %@, %@", error, error.localizedDescription);
    }
    [self selectDefaultRow];
}

- (void)selectDefaultRow{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedObjectID && [self.pickerData count] > 0) {
        CoreDataHelper * cdh = [(AppDelegate *)[UIApplication sharedApplication].delegate chd];
        LocationAtShop * selectedObject = (LocationAtShop *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtShop * locationAtShop, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([locationAtShop.aisle compare:selectedObject.aisle] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectObjectID:self.selectedObjectID changeForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    LocationAtShop * locationAtHome = [self.pickerData objectAtIndex:row];
    return locationAtHome.aisle;
}

@end

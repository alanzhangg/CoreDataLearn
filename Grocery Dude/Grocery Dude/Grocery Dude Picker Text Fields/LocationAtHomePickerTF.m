//
//  LocationAtHomePickerTF.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/27.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "LocationAtHomePickerTF.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "LocationAtHome+CoreDataClass.h"

@implementation LocationAtHomePickerTF

#define debug 1

- (void)fetch{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[UIApplication sharedApplication].delegate chd];
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"storedIn" ascending:YES];
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
        LocationAtHome * selectedObject = (LocationAtHome *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtHome * locationAtHome, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([locationAtHome.storedIn compare:selectedObject.storedIn] == NSOrderedSame) {
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
    LocationAtHome * locationAtHome = [self.pickerData objectAtIndex:row];
    return locationAtHome.storedIn;
}

@end

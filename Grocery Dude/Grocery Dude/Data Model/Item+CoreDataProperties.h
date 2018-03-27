//
//  Item+CoreDataProperties.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/16.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Item+CoreDataClass.h"
#import "LocationAtHome+CoreDataClass.h"
#import "LocationAtShop+CoreDataClass.h"
#import "Unit+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *collected;
@property (nullable, nonatomic, copy) NSNumber *listed;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSData *photoData;
@property (nullable, nonatomic, copy) NSNumber *quantity;
@property (nullable, nonatomic, retain) Unit *unit;
@property (nullable, nonatomic, retain) LocationAtHome *locationAtHome;
@property (nullable, nonatomic, retain) LocationAtShop *locationAtShop;

@end

NS_ASSUME_NONNULL_END

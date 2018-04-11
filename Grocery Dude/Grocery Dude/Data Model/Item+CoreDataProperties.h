//
//  Item+CoreDataProperties.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Item+CoreDataClass.h"
#import "LocationAtHome+CoreDataProperties.h"
#import "LocationAtShop+CoreDataProperties.h"
#import "Unit+CoreDataProperties.h"
#import "Item_photo+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *collected;
@property (nullable, nonatomic, copy) NSNumber *listed;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) LocationAtHome *locationAtHome;
@property (nullable, nonatomic, retain) LocationAtShop *locationAtShop;
@property (nullable, nonatomic, retain) Unit *unit;
@property (nullable, nonatomic, retain) Item_photo *photo;

@end

NS_ASSUME_NONNULL_END

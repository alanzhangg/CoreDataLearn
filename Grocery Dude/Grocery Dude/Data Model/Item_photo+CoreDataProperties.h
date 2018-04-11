//
//  Item_photo+CoreDataProperties.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Item_photo+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Item_photo (CoreDataProperties)

+ (NSFetchRequest<Item_photo *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) Item *item;

@end

NS_ASSUME_NONNULL_END

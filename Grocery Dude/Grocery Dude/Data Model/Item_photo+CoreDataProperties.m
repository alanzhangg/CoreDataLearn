//
//  Item_photo+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Item_photo+CoreDataProperties.h"

@implementation Item_photo (CoreDataProperties)

+ (NSFetchRequest<Item_photo *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Item_photo"];
}

@dynamic data;
@dynamic item;

@end

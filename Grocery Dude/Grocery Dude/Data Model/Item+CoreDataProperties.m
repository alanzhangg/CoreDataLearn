//
//  Item+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Item+CoreDataProperties.h"

@implementation Item (CoreDataProperties)

+ (NSFetchRequest<Item *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Item"];
}

@dynamic collected;
@dynamic listed;
@dynamic name;
@dynamic quantity;
@dynamic thumbnail;
@dynamic locationAtHome;
@dynamic locationAtShop;
@dynamic unit;
@dynamic photo;

@end

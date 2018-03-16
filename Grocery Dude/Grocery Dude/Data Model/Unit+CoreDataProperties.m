//
//  Unit+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/16.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Unit+CoreDataProperties.h"

@implementation Unit (CoreDataProperties)

+ (NSFetchRequest<Unit *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Unit"];
}

@dynamic name;
@dynamic items;

@end

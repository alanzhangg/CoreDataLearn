//
//  Unit+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Unit+CoreDataProperties.h"

@implementation Unit (CoreDataProperties)

+ (NSFetchRequest<Unit *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
}

@dynamic name;
@dynamic items;

@end

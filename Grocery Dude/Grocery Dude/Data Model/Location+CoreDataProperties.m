//
//  Location+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "Location+CoreDataProperties.h"

@implementation Location (CoreDataProperties)

+ (NSFetchRequest<Location *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Location"];
}

@dynamic summary;

@end

//
//  LocationAtShop+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "LocationAtShop+CoreDataProperties.h"

@implementation LocationAtShop (CoreDataProperties)

+ (NSFetchRequest<LocationAtShop *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
}

@dynamic aisle;
@dynamic newRelationship;

@end

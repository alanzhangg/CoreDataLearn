//
//  LocationAtHome+CoreDataProperties.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/11.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "LocationAtHome+CoreDataProperties.h"

@implementation LocationAtHome (CoreDataProperties)

+ (NSFetchRequest<LocationAtHome *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
}

@dynamic storedIn;
@dynamic newRelationship;

@end

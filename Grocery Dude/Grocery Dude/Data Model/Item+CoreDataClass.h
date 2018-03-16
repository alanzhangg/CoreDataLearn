//
//  Item+CoreDataClass.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/16.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocationAtHome, LocationAtShop, Unit;

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"

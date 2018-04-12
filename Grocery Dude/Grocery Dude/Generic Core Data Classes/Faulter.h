//
//  Faulter.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/12.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Faulter : NSObject

+ (void)faultObjectWithID:(NSManagedObjectID *)objectID
                inContext:(NSManagedObjectContext *)context;

@end

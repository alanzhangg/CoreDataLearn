//
//  LocationAtShop+CoreDataProperties.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/16.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "LocationAtShop+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LocationAtShop (CoreDataProperties)

+ (NSFetchRequest<LocationAtShop *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *aisle;
@property (nullable, nonatomic, retain) NSSet<Item *> *newRelationship;

@end

@interface LocationAtShop (CoreDataGeneratedAccessors)

- (void)addNewRelationshipObject:(Item *)value;
- (void)removeNewRelationshipObject:(Item *)value;
- (void)addNewRelationship:(NSSet<Item *> *)values;
- (void)removeNewRelationship:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END

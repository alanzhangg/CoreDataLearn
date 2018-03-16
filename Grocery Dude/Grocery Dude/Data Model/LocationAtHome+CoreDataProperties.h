//
//  LocationAtHome+CoreDataProperties.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/16.
//  Copyright © 2018年 jilian. All rights reserved.
//
//

#import "LocationAtHome+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LocationAtHome (CoreDataProperties)

+ (NSFetchRequest<LocationAtHome *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *storedIn;
@property (nullable, nonatomic, retain) NSSet<Item *> *newRelationship;

@end

@interface LocationAtHome (CoreDataGeneratedAccessors)

- (void)addNewRelationshipObject:(Item *)value;
- (void)removeNewRelationshipObject:(Item *)value;
- (void)addNewRelationship:(NSSet<Item *> *)values;
- (void)removeNewRelationship:(NSSet<Item *> *)values;

@end

NS_ASSUME_NONNULL_END

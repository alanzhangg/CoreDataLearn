//
//  CoreDataImporter.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/28.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataImporter : NSObject

@property (nonatomic, strong) NSDictionary * entitiesWithUniqueAttributes;

+ (void)saveContext:(NSManagedObjectContext *)context;
- (CoreDataImporter *)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes;
- (NSString *)uniqueAttributeForEntity:(NSString *)entity;

- (NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity
                                 uniqueAttributeValue:(NSString *)uniqueAttributeValue
                                      attributeValues:(NSDictionary *)attributeValues
                                            inContext:(NSManagedObjectContext *)context;

- (NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity
                               targetEntityAttribute:(NSString *)targetEntityAttribute
                                  sourceXMLAttribute:(NSString *)sourceXMLAttribute
                                       attributeDict:(NSDictionary *)attributeDict
                                             context:(NSManagedObjectContext *)context;

@end

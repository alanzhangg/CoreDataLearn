//
//  CoreDataImporter.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/28.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "CoreDataImporter.h"

@implementation CoreDataImporter

#define debug 1

+ (void)saveContext:(NSManagedObjectContext *)context{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [context performBlockAndWait:^{
        if ([context hasChanges]) {
            NSError * error = nil;
            if ([context save:&error]) {
                NSLog(@"CoreDataImporter SAVE changes from context to persistent store");
            }else{
                NSLog(@"CoreDataImporter Failed to save changes from context to persistent store: %@", error);
            }
        }else{
            NSLog(@"CoreDataImporter SKIPPED saving context as there are no changes");
        }
    }];
}

- (CoreDataImporter *)initWithUniqueAttributes:(NSDictionary *)uniqueAttributes{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self = [super init]) {
        self.entitiesWithUniqueAttributes = uniqueAttributes;
        if (self.entitiesWithUniqueAttributes) {
            return self;
        }else{
            NSLog(@"FAILED to initialize CoreDataImporter: entitiesWithUniqueAttributes is nil");
            return nil;
        }
    }
    return nil;
}

- (NSString *)uniqueAttributeForEntity:(NSString *)entity{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self.entitiesWithUniqueAttributes valueForKey:entity];
}

- (NSManagedObject *)existingObjectInContext:(NSManagedObjectContext *)context
                                   forEntity:(NSString *)entity
                    withUniqueAttributeValue:(NSString *)uniqueAttributeValue{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString * uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K==%@", uniqueAttribute, uniqueAttributeValue];
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSError * error;
    NSAsynchronousFetchResult * result = [context executeRequest:fetchRequest error:&error];
    NSArray * fetchRequestResults = result.finalResult;
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    if (fetchRequestResults.count == 0) {
        return nil;
    }
    return fetchRequestResults.lastObject;
}

- (NSManagedObject *)insertUniqueObjectInTargetEntity:(NSString *)entity
                                 uniqueAttributeValue:(NSString *)uniqueAttributeValue
                                      attributeValues:(NSDictionary *)attributeValues
                                            inContext:(NSManagedObjectContext *)context{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString * uniqueAttribute = [self uniqueAttributeForEntity:entity];
    if (uniqueAttributeValue.length > 0) {
        NSManagedObject * existingObject = [self existingObjectInContext:context
                                                               forEntity:entity
                                            withUniqueAttributeValue:uniqueAttributeValue];
        if (existingObject) {
            NSLog(@"%@ object with %@ value '%@' already exists", entity, uniqueAttribute, uniqueAttributeValue);
            return existingObject;
        }else{
            NSManagedObject * newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributeValues];
            NSLog(@"Created %@ object with %@ '%@'", entity, uniqueAttribute, uniqueAttributeValue);
            return newObject;
        }
    }else{
        NSLog(@"Skipped %@ object creation: unique attribute value is 0 length", entity);
    }
    return nil;
}

- (NSManagedObject *)insertBasicObjectInTargetEntity:(NSString *)entity
                               targetEntityAttribute:(NSString *)targetEntityAttribute
                                  sourceXMLAttribute:(NSString *)sourceXMLAttribute
                                       attributeDict:(NSDictionary *)attributeDict
                                             context:(NSManagedObjectContext *)context{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSArray * attribute = @[targetEntityAttribute];
    NSArray * values = @[[attributeDict valueForKey:sourceXMLAttribute]];
    NSDictionary * attributeValues = [NSDictionary dictionaryWithObjects:values forKeys:attribute];
    return [self insertUniqueObjectInTargetEntity:entity uniqueAttributeValue:[attributeDict valueForKey:sourceXMLAttribute] attributeValues:attributeValues inContext:context];
}

#pragma mark - DEEP COPY

- (NSString *)objectInfo:(NSManagedObject *)object{
    if (!object) {
        return nil;
    }
    NSString * entity = object.entity.name;
    NSString * uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString * uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    return [NSString stringWithFormat:@"%@ '%@'", entity, uniqueAttributeValue];
}

- (NSArray *)arrayForEntity:(NSString *)entity
                  inContext:(NSManagedObjectContext *)context
              withPredicate:(NSPredicate *)predicate{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setFetchBatchSize:20];
    [request setPredicate:predicate];
    NSError * error;
    NSAsynchronousFetchResult * result = [context executeRequest:request error:&error];
    NSArray * array = result.finalResult;
    if (error) {
        NSLog(@"ERROR fetching objects: %@", error.localizedDescription);
    }
    return array;
}

- (NSManagedObject *)copyUniqueObject:(NSManagedObject *)object
                            toContext:(NSManagedObjectContext *)targetContext{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!object || !targetContext) {
        NSLog(@"FAILED to copy %@ to context %@", [self objectInfo:object], targetContext);
        return nil;
    }
    NSString * entity = object.entity.name;
    NSString * uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString * uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    if (uniqueAttributeValue.length > 0) {
        NSMutableDictionary * attributeValuesToCopy = [NSMutableDictionary new];
        for (NSString * attribute in object.entity.attributesByName) {
            if ([object valueForKey:attribute]) {
                [attributeValuesToCopy setObject:[[object valueForKey:attribute] copy] forKey:attribute];
            }
        }
        NSManagedObject * coppiedObject = [self insertUniqueObjectInTargetEntity:entity
                                                            uniqueAttributeValue:uniqueAttributeValue
                                                        attributeValues:attributeValuesToCopy inContext:targetContext];
        return coppiedObject;
    }
    return nil;
}

- (void)establishToOneRelationship:(NSString *)relationshipName
                        fromObject:(NSManagedObject *)object
                          toObject:(NSManagedObject *)relatedObject{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!relationshipName || !object || !relatedObject) {
        NSLog(@"SKIPPED establishing To-One relationship '%@' between %@ and %@",
              relationshipName,
              [self objectInfo:object],
              [self objectInfo:relatedObject]);
        NSLog(@"Due to missing Info!");
        return;
    }
    
    NSManagedObject * existingRelatedObject = [object valueForKey:relationshipName];
    if (existingRelatedObject) {
        return;
    }
    
    NSDictionary * relationships = [object.entity relationshipsByName];
    NSRelationshipDescription * relationship = [relationships objectForKey:relationshipName];
    if (![relatedObject.entity isEqual:relationship.destinationEntity]) {
        NSLog(@"%@ id the of wrog entity type to relate to %@", [self objectInfo:object], [self objectInfo:relatedObject]);
        return;
    }
    
    [object setValue:relatedObject forKey:relationshipName];
    NSLog(@"ESTABLISHED %@ relationship from %@ to %@",
          relationshipName,
          [self objectInfo:object],
          [self objectInfo:relatedObject]);
    
    [CoreDataImporter saveContext:relatedObject.managedObjectContext];
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
    [relatedObject.managedObjectContext refreshObject:relatedObject mergeChanges:NO];
}

- (void)establishToManyRelationship:(NSString *)relationshipName
                         fromObject:(NSManagedObject *)object
                      withSourceSet:(NSMutableSet *)sourceSet{
    if (!object || !sourceSet || !relationshipName) {
        NSLog(@"SKIPPED establishing a To-Many relationship from %@",
              [self objectInfo:object]);
        NSLog(@"Due to missing Info!");
        return;
    }
    NSMutableSet * copiedSet = [object mutableSetValueForKey:relationshipName];
    for (NSManagedObject * relatedObject in sourceSet) {
        NSManagedObject * copiedRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            NSLog(@"A copy of %@ is now related via To-Many '%@' relationship to %@",
                  [self objectInfo:object],
                  relationshipName,
                  [self objectInfo:copiedRelatedObject]);
        }
    }
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)establishOrderedToManyRelationship:(NSString *)relationshipName
                                fromObject:(NSManagedObject *)object
                             withSourceSet:(NSMutableOrderedSet *)sourceSet{
    if (!object || !sourceSet || !relationshipName) {
        NSLog(@"Skipped establishment of an Ordered To-Many relationship from %@",
              [self objectInfo:object]);
        NSLog(@"Due to missing Info!");
        return;
    }
    
    NSMutableOrderedSet * copiedSet = [self mutableOrderedSetValueForKey:relationshipName];
    
    for (NSManagedObject * relatedObject in sourceSet) {
        NSManagedObject * copiedRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            NSLog(@"A copy of %@ is related via Ordered To-Many '%@' relationship to %@",[self objectInfo:object], relationshipName, [self objectInfo:copiedRelatedObject]);
        }
    }
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)copyRelationshipsFromObject:(NSManagedObject *)sourceObject
                          toContext:(NSManagedObjectContext *)targetContext{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!sourceObject || !targetContext) {
        NSLog(@"Failed to copy relationships from '%@' to context '%@'", [self objectInfo:sourceObject], targetContext);
        return;
    }
    
    NSManagedObject * copiedObject = [self copyUniqueObject:sourceObject toContext:targetContext];
    if (!copiedObject) {
        return;
    }
    
    // copy relationships
    NSDictionary * relationships = [sourceObject.entity relationshipsByName];
    for (NSString * relationshipName in relationships) {
        
        NSRelationshipDescription * relationship = [relationships objectForKey:relationshipName];
        if ([sourceObject valueForKey:relationshipName]) {
            if (relationship.isToMany && relationship.isOrdered) {
                NSMutableOrderedSet * sourceSet = [sourceObject mutableOrderedSetValueForKey:relationshipName];
                [self establishOrderedToManyRelationship:relationshipName
                                              fromObject:copiedObject
                                           withSourceSet:sourceSet];
            }else if (relationship.isToMany && !relationship.isOrdered){
                NSMutableSet * souceSet = [sourceObject mutableSetValueForKey:relationshipName];
                [self establishToManyRelationship:relationshipName
                                       fromObject:copiedObject
                                    withSourceSet:souceSet];
            }else{
                NSManagedObject * relatedSourceObject = [sourceObject valueForKey:relationshipName];
                NSManagedObject * relatedCopiedObject = [self copyUniqueObject:relatedSourceObject toContext:targetContext];
                [self establishToOneRelationship:relationshipName
                                      fromObject:copiedObject
                                        toObject:relatedCopiedObject];
            }
        }
    }
}

- (void)deepCopyEntities:(NSArray *)entities
             fromContext:(NSManagedObjectContext *)sourceContext
               toContext:(NSManagedObjectContext *)targetContext{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    for (NSString * entity in entities) {
        NSLog(@"COPYING %@ objects to target context...", entity);
        NSArray * sourceObjects = [self arrayForEntity:entity inContext:sourceContext withPredicate:nil];
        for (NSManagedObject * sourceObject in sourceObjects) {
            if (sourceObject) {
                @autoreleasepool{
                    [self copyUniqueObject:sourceObject toContext:targetContext];
                    [self copyRelationshipsFromObject:sourceObject toContext:targetContext];
                }
            }
        }
    }
}

@end

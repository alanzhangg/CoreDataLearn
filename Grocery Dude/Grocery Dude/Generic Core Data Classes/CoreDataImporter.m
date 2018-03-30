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



@end

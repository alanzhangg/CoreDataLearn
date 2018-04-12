//
//  Thumbernailer.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/12.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "Thumbernailer.h"
#import "Faulter.h"
#import <UIKit/UIKit.h>

@implementation Thumbernailer

#define debug 1

+ (void)createMissingThumbnailsForEntityName:(NSString *)entityName
                  withThumbnailAttributeName:(NSString *)thumbnailAttributeName
                   withPhotoRelationshipName:(NSString *)photoRelationshipName
                      withPhotoAttributeName:(NSString *)photoAttributeName
                         withSortDescriptors:(NSArray *)sortDescriptors
                           withImportContext:(NSManagedObjectContext *)importContext{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [importContext performBlock:^{
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.predicate = [NSPredicate predicateWithFormat:@"%K==nil && %K.%K != nil", thumbnailAttributeName, photoRelationshipName, photoAttributeName];
        request.sortDescriptors = sortDescriptors;
        request.fetchBatchSize = 15;
        NSError * error;
        NSAsynchronousFetchResult * result = [importContext executeRequest:request error:&error];
        NSArray * missingThumbnails = result.finalResult;
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        for (NSManagedObject * object in missingThumbnails) {
            NSManagedObject * photoObject = [object valueForKey:photoRelationshipName];
            if (![object valueForKey:thumbnailAttributeName] && [photoObject valueForKey:photoAttributeName]) {
                
                UIImage * photo = [UIImage imageWithData:[photoObject valueForKey:photoAttributeName]];
                CGSize size = CGSizeMake(66, 66);
                UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                [photo drawInRect:CGRectMake(0, 0, size.width, size.height)];
                UIImage * thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [object setValue:UIImagePNGRepresentation(thumbnail) forKey:thumbnailAttributeName];
                
                [Faulter faultObjectWithID:photoObject.objectID inContext:importContext];
                [Faulter faultObjectWithID:object.objectID inContext:importContext];
                
                photo = nil;
                thumbnail = nil;
            }
        }
    }];
}

@end

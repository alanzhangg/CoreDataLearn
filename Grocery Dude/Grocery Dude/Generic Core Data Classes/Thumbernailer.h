//
//  Thumbernailer.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/4/12.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Thumbernailer : NSObject

+ (void)createMissingThumbnailsForEntityName:(NSString *)entityName
                  withThumbnailAttributeName:(NSString *)thumbnailAttributeName
                   withPhotoRelationshipName:(NSString *)photoRelationshipName
                      withPhotoAttributeName:(NSString *)photoAttributeName
                         withSortDescriptors:(NSArray *)sortDescriptors
                           withImportContext:(NSManagedObjectContext *)importContext;

@end

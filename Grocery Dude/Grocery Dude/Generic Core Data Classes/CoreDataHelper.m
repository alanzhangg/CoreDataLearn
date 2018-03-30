//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/5.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "CoreDataHelper.h"
#import "CoreDataImporter.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES
NSString * storeFileName = @"Grocery-Dude.sqlite";

#pragma mark - DELEGATE: UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (alertView == self.importAlertView) {
        if (buttonIndex == 1) {
            NSLog(@"Default Data Import Approved by User");
            [_importContext performBlock:^{
                [self importFromXML:[[NSBundle mainBundle] URLForResource:@"DefaultData" withExtension:@"xml"]];
            }];
        }else{
            NSLog(@"Default Data Import Cancelled by User");
        }
        [self setDefaultDataAsImportedForStore:_store];
    }
}

#pragma mark - PATHS

- (NSString *)applicationDocumentsDirectory{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoreDirection{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSURL * storeDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Store"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[storeDirectory path]]) {
        NSError * error = nil;
        if ([fileManager createDirectoryAtURL:storeDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (debug == 1) {
                NSLog(@"Successfully");
            }else
                NSLog(@"Failed");
        }
    }
    
    return storeDirectory;
}

- (NSURL *)storeURL{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoreDirection] URLByAppendingPathComponent:storeFileName];
}

#pragma mark - SETUP

- (instancetype)init{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {
        return nil;
    }
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    
    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        [_importContext setPersistentStoreCoordinator:_coordinator];
        [_importContext setUndoManager:nil];
    }];
    return self;
}

- (void)loadStore{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    
    BOOL useMigrationManager = YES;
    if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    }else{
        NSError * error = nil;
        NSDictionary * options = @{
//                                   NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},
                                   NSMigratePersistentStoresAutomaticallyOption:@YES,
                                   NSInferMappingModelAutomaticallyOption:@NO
                                   };
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
        if (!_store) {
            NSLog(@"Fail");
            abort();
        }else{
            if (debug == 1) {
                NSLog(@"Successfully %@", _store);
            }
        }
    }
}

- (void)setupCoreData{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self loadStore];
    [self checkIfDefaultDataNeedsImporting];

}

#pragma mark - SAVING

- (void)saveContext{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError * error = nil;
        if ([_context save:&error]) {
            NSLog(@"save");
        }else{
            NSLog(@"Failed %@", error);
            [self showValidationError:error];
        }
    }else
        NSLog(@"Skipped");
}

#pragma mark - MIGRATION MANAGER

- (BOOL)isMigrationNecessaryForStore:(NSURL *)storeUrl{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug == 1) {
            NSLog(@"Skipped migration");
        }
        return NO;
    }
    NSError * error = nil;
    NSDictionary * sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl error:&error];
    NSManagedObjectModel * destinationModel = _coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if (debug == 1) {
            NSLog(@"SKIPPED MIGRATION");
        }
        return NO;
    }
    return YES;
}

- (BOOL)migrationStore:(NSURL *)sourceStore{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError * error = nil;
    
    NSDictionary * sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore error:&error];
    
    NSManagedObjectModel * sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetaData];
    
    NSManagedObjectModel * destinModel = _model;
    NSMappingModel * mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
    if (mappingModel) {
        NSError * error = nil;
        NSMigrationManager * migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSURL * destinStore = [[self applicationStoreDirection] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        if (success) {
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                if (debug == 1) {
                    NSLog(@"successfully");
                }
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }else{
                if (debug == 1) {
                    NSLog(@"Filed");
                }
            }
        }else{
            if (debug == 1) {
                NSLog(@"Failed");
            }
        }
    }else{
        if (debug == 1) {
            NSLog(@"failed");
        }
    }
    return YES;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString * str = [NSString stringWithFormat:@"Migration Process %i%%", percentage];
            NSLog(@"%@", str);
            self.migrationVC.label.text = str;
        });
    }
}

- (BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new{
    BOOL success = NO;
    NSError * error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        }else{
            if (debug == 1) {
                NSLog(@"Failed");
            }
        }
    }else{
        if (debug == 1) {
            NSLog(@"Failed");
        }
    }
    return success;
}

- (void)performBackgroundManagedMigrationForStore:(NSURL *)storeUrl{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"MigrationC"];
    UIApplication * sa = [UIApplication sharedApplication];
    UINavigationController * nc = (UINavigationController *)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:NO completion:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrationStore:storeUrl];
        if (done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError * error = nil;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
                if (!_store) {
                    NSLog(@"Failed %@", error);
                    abort();
                }else{
                    NSLog(@"Successfully %@", _store);
                }
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
        }
    });
}

#pragma mark - VALIDATION ERROR HANDING

- (void)showValidationError:(NSError *)anError{
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray * errors = nil;
        NSString * txt = @"";
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }else{
            errors = [NSArray arrayWithObject:anError];
        }
        
        if (errors && errors.count > 0) {
            for (NSError * error in errors) {
                
                NSString * entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString * property = [error.userInfo objectForKey:@"NSValidationErrorKey"];
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:@"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
                        break;
                        
                    default:
                        txt = [txt stringByAppendingFormat:@"Unhandled error code %li in showValidationError method", (long)error.code];
                        break;
                }
            }
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Validation Error" message:txt delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
        
    }
}

#pragma mark - DATA IMPORT

- (BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL *)url ofType:(NSString *)type{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError * error;
    NSDictionary * dictionary = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:url error:&error];
    if (error) {
        NSLog(@"Error reading persistent store metadata: %@", error.localizedDescription);
    }else{
        NSNumber * defaultDataAlreadyImported = [dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataAlreadyImported boolValue]) {
            NSLog(@"Default Data has NOT already been iported");
            return NO;
        }
    }
    if (debug == 1) {
        NSLog(@"Default Data HAS already been imported");
    }
    return YES;
}

- (void)checkIfDefaultDataNeedsImporting{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![self isDefaultDataAlreadyImportedForStoreWithURL:[self storeURL] ofType:NSSQLiteStoreType]) {
        _importAlertView = [[UIAlertView alloc] initWithTitle:@"Import Default Data" message:@"If you're never used me" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil] ;
        [self.importAlertView show];
    }
}

- (void)importFromXML:(NSURL *)url{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"**** START PARSE OF %@", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    NSLog(@"**** END PARSE OF %@", url.path);
}

- (void)setDefaultDataAsImportedForStore:(NSPersistentStore *)aStore{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //get metadata dictionary
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    if (debug == 1) {
        NSLog(@"__Store MetaData BEFORE changes__ \n %@", dictionary);
    }
    //edit metadata dictionary
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    
    //set metadata dictionary
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
    if (debug == 1) {
        NSLog(@"__Store Metadata AFTER changes__ \n %@", dictionary);
    }
}

#pragma mark - UNIQUE ATTRIBUTE SELECTION (this code is Grocery Dude data specific and is used when instantiating CoreDataImporter)

- (NSDictionary *)selectedUniqueAttributes{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray * entities = [NSMutableArray new];
    NSMutableArray * attributes = [NSMutableArray new];
    
    [entities addObject:@"Item"];[attributes addObject:@"name"];
    [entities addObject:@"Unit"];[attributes addObject:@"name"];
    [entities addObject:@"LocationAtHome"];[attributes addObject:@"storedIn"];
    [entities addObject:@"LocationAtShop"];[attributes addObject:@"aisle"];
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjects:attributes forKeys:entities];
    return dictionary;
}

#pragma mark - DELEGATE:NSXMLParser (This code is Grocery Dude data specific)

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    [self.importContext performBlockAndWait:^{
        //STEP1: Process only the 'item' element in the XML file
        if ([elementName isEqualToString:@"item"]) {
            //STEP2: Prepare the Core Data Importer
            CoreDataImporter * importer = [[CoreDataImporter alloc] initWithUniqueAttributes:[self selectedUniqueAttributes]];
            
            //STEP3A: Insert a unique 'Item' object
            NSManagedObject * item = [importer insertBasicObjectInTargetEntity:@"Item" targetEntityAttribute:@"name" sourceXMLAttribute:@"name" attributeDict:attributeDict context:_importContext];
            
            //STEP3B: Insert a unique 'Unit' object
            NSManagedObject * unit = [importer insertBasicObjectInTargetEntity:@"Unit" targetEntityAttribute:@"name" sourceXMLAttribute:@"unit" attributeDict:attributeDict context:_importContext];
            
            //STEP 3C: Insert a unique 'LocationAtHome' object
            NSManagedObject * locationAtHome = [importer insertBasicObjectInTargetEntity:@"LocationAtHome" targetEntityAttribute:@"storedIn" sourceXMLAttribute:@"locationathome" attributeDict:attributeDict context:_importContext];
            //STEP3D: Insert a unique 'LocationAtShop' object
            NSManagedObject * locationAtShop = [importer insertBasicObjectInTargetEntity:@"LocationAtShop" targetEntityAttribute:@"aisle" sourceXMLAttribute:@"locationatshop" attributeDict:attributeDict context:_importContext];
            
            //STEP 4: Manually add extra attribute values.
            [item setValue:@NO forKey:@"listed"];
            
            //STEP 5: Create relationships
            [item setValue:unit forKey:@"unit"];
            [item setValue:locationAtHome forKey:@"locationAtHome"];
            [item setValue:locationAtShop forKey:@"locationAtShop"];
            
            //STEP 6: Save new objects to the persistent
            [CoreDataImporter saveContext:_importContext];
            
            //STEP 7: Save new objects into faults to save memory
            [_importContext refreshObject:item mergeChanges:NO];
            [_importContext refreshObject:unit mergeChanges:NO];
            [_importContext refreshObject:locationAtHome mergeChanges:NO];
            [_importContext refreshObject:locationAtShop mergeChanges:NO];
            
        }
    }];
}

@end

//
//  CoreDataPickerTF.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/27.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@class CoreDataPickerTF;

@protocol CoreDataPickerTFDelegate <NSObject>
- (void)selectObjectID:(NSManagedObjectID *)objectID changeForPickerTF:(CoreDataPickerTF *)pickerTF;

@optional
- (void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF;
@end

@interface CoreDataPickerTF : UITextField<UIKeyInput, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id<CoreDataPickerTFDelegate> pickerDelegate;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSArray * pickerData;
@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, assign) BOOL showToolBar;
@property (nonatomic, strong) NSManagedObjectID * selectedObjectID;

- (void)fetch;
- (void)selectDefaultRow;

@end

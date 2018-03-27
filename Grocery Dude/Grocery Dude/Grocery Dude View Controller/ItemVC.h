//
//  ItemVC.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/21.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "UnitPickerTF.h"

@interface ItemVC : UIViewController

@property (strong, nonatomic) NSManagedObjectID * selectedItemID;

@end

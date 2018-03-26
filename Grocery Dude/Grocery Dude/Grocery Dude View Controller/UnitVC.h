//
//  UnitVC.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/26.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface UnitVC : UIViewController

@property (nonatomic, strong) NSManagedObjectID * selectedObjectID;
@property (nonatomic, strong) IBOutlet UITextField * nameTextField;

@end

//
//  PrepareTVC.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/9.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "CoreDataTVC.h"

@interface PrepareTVC : CoreDataTVC<UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet * clearConfirmActionSheet;

@end

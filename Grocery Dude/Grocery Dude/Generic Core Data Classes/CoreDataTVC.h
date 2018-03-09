//
//  CoreDataTVC.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/7.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface CoreDataTVC : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController * frc;
- (void)performFetch;

@end

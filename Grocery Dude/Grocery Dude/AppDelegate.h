//
//  AppDelegate.h
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/2.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper * coreDataHelper;

@end


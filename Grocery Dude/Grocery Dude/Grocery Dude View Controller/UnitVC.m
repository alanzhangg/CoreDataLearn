//
//  UnitVC.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/26.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "UnitVC.h"
#import "Unit+CoreDataClass.h"
#import "AppDelegate.h"

@interface UnitVC ()<UITextFieldDelegate>

@end

@implementation UnitVC

#define debug 1

#pragma mark - TEXTFIELD

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    Unit * unit = (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
    if (textField == self.nameTextField) {
        unit.name = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    }
}

#pragma mark - VIEW

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self hideKeyboardWhenBackgroundIsTapped];
    self.nameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self refreshInterface];
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshInterface{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedObjectID) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Unit * unit = (Unit *)[cdh.context existingObjectWithID:self.selectedObjectID error:nil];
        self.nameTextField.text = unit.name;
    }
}

#pragma mark - INTERACTION

- (IBAction)done:(id)sender{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboardWhenBackgroundIsTapped{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)hideKeyboard{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.view endEditing:YES];
}

@end

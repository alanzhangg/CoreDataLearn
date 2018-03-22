//
//  ItemVC.m
//  Grocery Dude
//
//  Created by alanzhangg on 2018/3/21.
//  Copyright © 2018年 jilian. All rights reserved.
//

#import "ItemVC.h"
#import "AppDelegate.h"
#import "Item+CoreDataProperties.h"

@interface ItemVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;

@end

@implementation ItemVC

#define debug 1

#pragma mark - DELEGATE: UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (textField == _nameTextField) {
        if ([self.nameTextField.text isEqualToString:@"New Item"]) {
            self.nameTextField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    Item * item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
    if (textField == self.nameTextField) {
        if ([self.nameTextField.text isEqualToString:@""]) {
            self.nameTextField.text = @"New Item";
        }
        item.name = self.nameTextField.text;
    }else if (textField == self.quantityTextField){
        item.quantity = @(self.quantityTextField.text.floatValue);
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
    self.quantityTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    [self refreshInterface];
    if ([self.nameTextField.text isEqualToString:@"New Item"]) {
        self.nameTextField.text = @"";
        [self.nameTextField becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidDisappear:animated];
    [self ensureItemHomeLocationIsNotNull];
    [self ensureItemShopLocationIsNotNull];
    CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
    [cdh saveContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshInterface{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Item * item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        self.nameTextField.text = item.name;
        self.quantityTextField.text = item.quantity.stringValue;
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

#pragma mark -DATA

- (void)ensureItemHomeLocationIsNotNull{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Item * item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (!item.locationAtHome) {
            NSFetchRequest * request = [[cdh model] fetchRequestTemplateForName:@"UnknowLocationAtHome"];
            NSAsynchronousFetchResult * result = [[cdh context] executeRequest:request error:nil];
            if (result.finalResult.count > 0) {
                item.locationAtHome = result.finalResult[0];
            }else{
                LocationAtHome * locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
                NSError * error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:@[locationAtHome] error:&error]) {
                    NSLog(@"Couldn't obtain a permanent ID for object %@", error);
                }
                locationAtHome.storedIn = @"..UnknownLocation..";
                item.locationAtHome = locationAtHome;
            }
        }
    }
}

- (void)ensureItemShopLocationIsNotNull{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Item * item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (!item.locationAtShop) {
            NSFetchRequest * request = [[cdh model] fetchRequestTemplateForName:@"UnknowLocationAtShop"];
            NSAsynchronousFetchResult * result = [[cdh context] executeRequest:request error:nil];
            if (result.finalResult.count > 0) {
                item.locationAtShop = result.finalResult[0];
            }else{
                LocationAtShop * locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
                NSError * error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:@[locationAtShop] error:&error]) {
                    NSLog(@"Couldn't obtain a permanent ID for object %@", error);
                }
                locationAtShop.aisle = @"..UnknownLocation..";
                item.locationAtShop = locationAtShop;
            }
        }
    }
}


@end

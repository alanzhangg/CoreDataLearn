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
#import "LocationAtHomePickerTF.h"
#import "LocationAtShopPickerTF.h"

@interface ItemVC ()<UITextFieldDelegate, CoreDataPickerTFDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UnitPickerTF *unitPickerTextField;
@property (weak, nonatomic) IBOutlet LocationAtHomePickerTF *homeLocationPickerTextField;
@property (weak, nonatomic) IBOutlet LocationAtShopPickerTF *shopLocationPickerTextField;
@property (strong, nonatomic) IBOutlet UITextField * activeField;
@end

@implementation ItemVC

#define debug 1

#pragma mark - PICKERS

- (void)selectObjectID:(NSManagedObjectID *)objectID changeForPickerTF:(CoreDataPickerTF *)pickerTF{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Item * item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        NSError * error;
        if (pickerTF == self.unitPickerTextField) {
            Unit * unit = (Unit *)[cdh.context existingObjectWithID:objectID error:&error];
            item.unit = unit;
            self.unitPickerTextField.text = unit.name;
        }else if (pickerTF == self.homeLocationPickerTextField){
            LocationAtHome * locationAtHome = (LocationAtHome *)[cdh.context existingObjectWithID:objectID error:&error];
            item.locationAtHome = locationAtHome;
            self.homeLocationPickerTextField.text = item.locationAtHome.storedIn;
        }else if (pickerTF == self.shopLocationPickerTextField){
            LocationAtShop * locationAtShop = (LocationAtShop *)[cdh.context existingObjectWithID:objectID error:&error];
            item.locationAtShop = locationAtShop;
            self.shopLocationPickerTextField.text = item.locationAtShop.aisle;
        }
        [self refreshInterface];
        if (error) {
            NSLog(@"Error selecting object on pickers: %@ %@", error, error.localizedDescription);
        }
    }
}

- (void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (self.selectedItemID) {
        CoreDataHelper * cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] chd];
        Item * item = (Item *)[cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (pickerTF == self.unitPickerTextField) {
            item.unit = nil;
            self.unitPickerTextField.text = @"";
        }else if (pickerTF == self.homeLocationPickerTextField){
            item.locationAtHome = nil;
            self.homeLocationPickerTextField.text = @"";
        }else if (pickerTF == self.shopLocationPickerTextField){
            item.locationAtShop = nil;
            self.shopLocationPickerTextField.text = @"";
        }
        [self refreshInterface];
    }
}

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
    if (textField == _unitPickerTextField && _unitPickerTextField.picker) {
        [_unitPickerTextField fetch];
        [_unitPickerTextField.picker reloadAllComponents];
    }else if (textField == _homeLocationPickerTextField && _homeLocationPickerTextField.picker){
        [_homeLocationPickerTextField fetch];
        [_homeLocationPickerTextField.picker reloadAllComponents];
    }else if (textField == _shopLocationPickerTextField && _shopLocationPickerTextField.picker){
        [_shopLocationPickerTextField fetch];
        [_shopLocationPickerTextField.picker reloadAllComponents];
    }
    _activeField = textField;
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
    _activeField = nil;
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
    
    self.unitPickerTextField.delegate = self;
    self.unitPickerTextField.pickerDelegate = self;
    
    self.homeLocationPickerTextField.delegate = self;
    self.homeLocationPickerTextField.pickerDelegate = self;
    self.shopLocationPickerTextField.delegate = self;
    self.shopLocationPickerTextField.pickerDelegate = self;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        self.unitPickerTextField.text = item.unit.name;
        self.unitPickerTextField.selectedObjectID = item.unit.objectID;
        self.homeLocationPickerTextField.text = item.locationAtHome.storedIn;
        self.homeLocationPickerTextField.selectedObjectID = item.locationAtHome.objectID;
        self.shopLocationPickerTextField.text = item.locationAtShop.aisle;
        self.shopLocationPickerTextField.selectedObjectID = item.locationAtShop.objectID;
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

- (void)keyboardDidShow:(NSNotification *)n{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CGRect keyboardRect = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect toView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    CGRect newScrollViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, keyboardTop);
    newScrollViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    [self.scrollView setFrame:newScrollViewFrame];
    [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)n{
    if (debug == 1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CGRect defaultFrame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.scrollView setFrame:defaultFrame];
    [self.scrollView scrollRectToVisible:self.nameTextField.frame animated:YES];
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

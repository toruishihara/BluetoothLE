//
//  ViewController.m
//  MyBLEPeripheral
//
//  Created by Toru Ishihara on 2015/11/14.
//  Copyright © 2015年 Toru Ishihara. All rights reserved.
//

#import "ViewController.h"
#import "PeripheralController.h"

@interface ViewController ()
@property (strong) PeripheralController *peripheralController;

@end

@implementation ViewController

- (IBAction)OnClick:(id)sender {
    NSLog(@"OnClick");
    [_peripheralController advertise];
    [_peripheralController updatePeripheralValue:99];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _peripheralController = [PeripheralController alloc];
    [_peripheralController initPeripheralController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

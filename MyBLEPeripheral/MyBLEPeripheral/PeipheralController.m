//
//  PeipheralController.m
//  MyBLEPeripheral
//
//  Created by Toru Ishihara on 2015/11/14.
//  Copyright © 2015年 Toru Ishihara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeripheralController.h"
@import CoreBluetooth;

#define CHARACTERISTIC_UUID @"7F855F82-9378-4508-A3D2-CD989104AF22"
#define SERVICE_UUID @"2B1DA6DE-9C29-4D6C-A930-B990EA2F12BB"

@interface PeripheralController() < CBPeripheralManagerDelegate >
@property (strong, nonatomic) CBPeripheralManager       *cpmPeripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *cmcCharacteristic;
@property (strong, nonatomic) NSMutableData             *mdtSendValue;
@property (strong, nonatomic) NSString                  *strGotValue;
@property (nonatomic) BOOL                              isSubscribed;
@property (strong, nonatomic) NSUUID *uuid;

@end
@implementation PeripheralController
- (void) initPeripheralController
{
    // PeripheralManagerの初期化. Delegateにselfを設定し、起動時にBluetoothがOffならアラートを表示する.
    NSLog(@"init");
    _cpmPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionShowPowerAlertKey:@YES}];
    
    _isSubscribed = NO;
    _strGotValue = @"";
}
- (void) close
{
    // Advertisingをストップ.
    [self.cpmPeripheralManager stopAdvertising];
}
- (NSString *) getCentralValue
{
    // Centralの書き込みリクエストで受け取った値を返す.
    return _strGotValue;
}


// Bluetoothの状態が変わったら実行される.
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"updateState state=%d", (int)peripheral.state);
    // BluetoothがOffならリターン.
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    // Characteristicの初期化. ここで設定したIDをもとにCentralが検索する.
    // Centralからの読み出し、書き込みを可能にする.
    _cmcCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHARACTERISTIC_UUID]
                                                            properties:(CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite)
                                                                 value:nil
                                                           permissions:(CBAttributePermissionsReadable|CBAttributePermissionsWriteable)];
    

    // Serviceの初期化. ここで設定したIDをもとにCentralがServiceを検索する.
    CBMutableService *cmsService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID]
                                                                  primary:YES];

    
    // ServiceのCharacteristicを設定する.
    cmsService.characteristics = @[_cmcCharacteristic];
    
    // PeripheralManagerにServiceを追加する.
    [_cpmPeripheralManager addService:cmsService];
    
    [self advertise];
}

-(void)advertise {
    NSLog(@"startAdvertising");
    // Advertisingの開始.Centralから探索可能にする.
    if (_uuid == nil) {
        _uuid = [[NSUUID alloc]initWithUUIDString:SERVICE_UUID];
    }
    NSDictionary *advertisementData = @{CBAdvertisementDataLocalNameKey: @"Test Device"};
    [_cpmPeripheralManager startAdvertising:advertisementData];
    //[_cpmPeripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : _uuid }];
}

// Peripheralで設定した値を更新したら、Centralに通知がいくようにする(Centralからのリクエストで実行).
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    _isSubscribed = YES;
}
- (BOOL) updatePeripheralValue:(int) intSendData
{
    if(_isSubscribed)
    {
        // Centralからの読み出しリクエストのための値を更新する.
        _mdtSendValue = (NSMutableData *)[[NSString stringWithFormat:@"%d", intSendData] dataUsingEncoding:NSUTF8StringEncoding];
        if([_cpmPeripheralManager updateValue:_mdtSendValue forCharacteristic:_cmcCharacteristic onSubscribedCentrals:nil])
        {
            return YES;
        }
    }
    return NO;
}
// Centralから書き込みリクエストを受けたら実行.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    for (CBATTRequest *rqs in requests) {
        if ([_cmcCharacteristic isEqual:rqs.characteristic])
        {
            _strGotValue = [[NSString alloc] initWithData:rqs.value encoding:NSUTF8StringEncoding];
            
            [_cpmPeripheralManager respondToRequest:rqs
                                         withResult:CBATTErrorSuccess];
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    NSLog(@"didAddService service=%@", service);
    if (error) {
        NSLog(@"error:%@", error);
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"didStartAd");
    if (error) {
        NSLog(@"error:%@", error);
    }
}

@end
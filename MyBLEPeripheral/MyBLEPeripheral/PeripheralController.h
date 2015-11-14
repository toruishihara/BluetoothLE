//
//  PeripheralController.h
//  MyBLEPeripheral
//
//  Created by Toru Ishihara on 2015/11/14.
//  Copyright © 2015年 Toru Ishihara. All rights reserved.
//

#ifndef PeripheralController_h
#define PeripheralController_h
@interface PeripheralController : NSObject
- (void) initPeripheralController;
- (void) close;
- (NSString *) getCentralValue;
- (BOOL) updatePeripheralValue:(int) intSendData;
@end

#endif /* PeripheralController_h */

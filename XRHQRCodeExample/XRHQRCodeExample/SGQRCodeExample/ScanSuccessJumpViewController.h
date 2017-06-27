//
//  ScanSuccessJumpViewController.h
//  XRHQRCodeExample
//
//  Created by xiangronghua on 2017/6/26.
//  Copyright © 2017年 xiangronghua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanSuccessJumpViewController : UIViewController

/** 接收扫描的二维码信息 */
@property (nonatomic, copy) NSString *jump_URL;
/** 接收扫描的条形码信息 */
@property (nonatomic, copy) NSString *jump_bar_code;

@end

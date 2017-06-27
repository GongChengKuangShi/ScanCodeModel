//
//  UIImage+SGHelper.h
//  XRHQRCodeExample
//
//  Created by xiangronghua on 2017/6/26.
//  Copyright © 2017年 xiangronghua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SGHelper)
/// 返回一张不超过屏幕尺寸的 image
+ (UIImage *)imageSizeWithScreenImage:(UIImage *)image;
@end

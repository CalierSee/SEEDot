//
//  UITextField+Dot.h
//  SEEDot
//
//  Created by 三只鸟 on 2018/2/9.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Dot)



/**
 开启/关闭 “.” 按钮支持 默认关闭

 @param enabled YES 开启 NO 关闭
 */
+ (void)dotEnabled:(BOOL)enabled;

@end

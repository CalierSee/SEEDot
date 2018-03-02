//
//  UITextField+Dot.m
//  SEEDot
//
//  Created by 三只鸟 on 2018/2/9.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "UITextField+Dot.h"
#import <objc/runtime.h>



const void * dotKey = @"dotEnabled";
const void * dotButtonKey = @"dotButton";
@interface UITextField ()

@property (strong, nonatomic) NSNumber * dotEnabled;

@property (strong, nonatomic) UIButton * dotButton;

@end

@implementation UITextField (Dot)


#pragma mark public method
+ (void)dotEnabled:(BOOL)enabled {
    if (enabled == [UITextField appearance].dotEnabled.boolValue) {
        return;
    }
    else {
        Method m1 = class_getInstanceMethod([UITextField class], @selector(becomeFirstResponder));
        Method m2 = class_getInstanceMethod([UITextField class], @selector(see_becomeFirstResponder));
        method_exchangeImplementations(m1, m2);
    }
    [UITextField appearance].dotEnabled = @(enabled);
}

#pragma mark action method
- (void)see_dotButtonAction {
    //修改长度
    NSUInteger len = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    NSString * replaceString = @".";
    //修改位置
    NSUInteger loc = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    //询问代理是否可以更改
    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(loc, len) replacementString:replaceString]) {
            [self see_replacingText:replaceString inRange:NSMakeRange(loc, len)];
        }
    }
    else {
        [self see_replacingText:replaceString inRange:NSMakeRange(loc, len)];
    }
}

- (void)see_dotButtonAnimateUp:(UIButton *)sender {
    if (@available(iOS 11, *)) {
    }
    else {
        sender.backgroundColor = [UIColor clearColor];
    }
}

- (void)see_dotButtonAnimateDown:(UIButton *)sender {
    if (@available(iOS 11, *)) {
    }
    else {
        sender.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark private method
- (void)see_becomeFirstResponder {
    uint8_t shouldAddDot = ![self isFirstResponder] << 2 | !self.dotButton.superview << 1 | self.keyboardType == UIKeyboardTypeNumberPad;
    [self see_becomeFirstResponder];
    //防止重复添加按钮
    if ((shouldAddDot & 0x7) == 0x7) {
        //找到键盘视图
        __block UIWindow * keyBoardWindow;
        [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isMemberOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]) {
                keyBoardWindow = obj;
                *stop = YES;
            }
        }];
        //找到父视图 添加小数点按钮
        __block UIView * targetView = [self see_findSuperOfKeyViewInViews:keyBoardWindow.subviews];
        if (targetView == nil) {
            return;
        }
        //找到位于键盘左下角的空白按钮
        UIView * keyView = targetView.subviews[targetView.subviews.count - 3];
        self.dotButton.frame = CGRectMake(keyView.frame.origin.x , keyView.frame.origin.y + 1, keyView.frame.size.width - 2, keyView.frame.size.height - 2);
        [targetView addSubview:self.dotButton];
    }
    else if ((shouldAddDot & 0x1) == 0x0){
        //当键盘类型不是NumberPad时移除小数点按钮
        [self.dotButton removeFromSuperview];
    }
}

/**
 寻找按钮父视图
 */
- (UIView *)see_findSuperOfKeyViewInViews:(NSArray <UIView *> *)views {
    __block UIView * target;
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:NSClassFromString(@"UIKBKeyView")]) {
            target = obj.superview;
        }
        else {
            target = [self see_findSuperOfKeyViewInViews:obj.subviews];
        }
        *stop = target;
    }];
    return target;
}

- (void)see_replacingText:(NSString *)text inRange:(NSRange)range {
    [self setText:[self.text stringByReplacingCharactersInRange:range withString:text]];
    [[NSNotificationCenter defaultCenter]postNotificationName:UITextFieldTextDidChangeNotification object:self];
}

#pragma mark getter & setter
- (void)setDotEnabled:(NSNumber *)dotEnabled {
    objc_setAssociatedObject(self, dotKey, dotEnabled, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)dotEnabled {
    return objc_getAssociatedObject(self, dotKey);
}

- (UIButton *)dotButton {
    if (objc_getAssociatedObject(self, dotButtonKey) == nil) {
        UIButton * dotButton = [[UIButton alloc]init];
        [dotButton setTitle:@"." forState:UIControlStateNormal];
        [dotButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        dotButton.titleLabel.font = [UIFont systemFontOfSize:30 weight:0.5];
        [dotButton addTarget:self action:@selector(see_dotButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [dotButton addTarget:self action:@selector(see_dotButtonAnimateDown:) forControlEvents:UIControlEventTouchDown];
        [dotButton addTarget:self action:@selector(see_dotButtonAnimateUp:) forControlEvents:UIControlEventTouchUpInside];
        [dotButton addTarget:self action:@selector(see_dotButtonAnimateUp:) forControlEvents:UIControlEventTouchUpOutside];
        objc_setAssociatedObject(self, dotButtonKey, dotButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, dotButtonKey);
}

- (void)setDotButton:(UIButton *)dotButton {
    objc_setAssociatedObject(self, dotButtonKey, dotButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

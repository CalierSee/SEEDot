//
//  ViewController.m
//  SEEDot
//
//  Created by 三只鸟 on 2018/2/9.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+Dot.h"
#import "SEEProxy.h"
#import "People.h"
#import "Fish.h"
@interface ViewController ()<UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UITextField dotEnabled:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(test:) name:UITextFieldTextDidChangeNotification object:nil];
    
    
    People * people = [[People alloc]init];
    Fish * fish = [[Fish alloc]init];
    
    SEEProxy * fishMan = [SEEProxy proxyWithObjs:people,fish, nil];
    
    [fishMan performSelector:@selector(say)];
    [fishMan performSelector:@selector(swimming)];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)test:(NSNotification *)noti {
    NSLog(@"%@",noti.object);
    NSLog(@"%@",noti.userInfo);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"%@",NSStringFromRange(range));
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

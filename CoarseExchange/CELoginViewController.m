//
//  ViewController.m
//  CoarseExchange
//
//  Created by stoull on 12/2/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CELoginViewController.h"
#import "CEConnectModel.h"

@interface CELoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


@end

@implementation CELoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}


#pragma -mark 登录动作
- (IBAction)loginClick:(id)sender {
    
    
    
    
    
    
}

// 设置服务器地址
- (IBAction)manageServiceAddress:(id)sender {
    
}



// 输入用户名密码时键盘动作
- (IBAction)endInputUsername:(id)sender {
    [self.passwordTextField becomeFirstResponder];
}
- (IBAction)endInputPassword:(id)sender {
    [self.passwordTextField resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end

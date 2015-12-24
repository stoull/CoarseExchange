//
//  CERegisterController.m
//  CoarseExchange
//
//  Created by stoull on 12/18/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CERegisterController.h"
#import "XMPPAssistant.h"
#import "MBProgressHUD.h"

@interface CERegisterController ()
{
    MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet UITextField *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;

@property (weak, nonatomic) IBOutlet UITextField *rePasswordLabel;


@property (weak, nonatomic) IBOutlet UIImageView *usernameHintimageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordHintImageView;
@property (weak, nonatomic) IBOutlet UIImageView *repasswordHintImageView;

@end

@implementation CERegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerClick:(id)sender {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    // 判断是否所有必需信息已填写完整
    if ([self.usernameLabel.text length] >0 && [self.passwordLabel.text length] >0 && [self.rePasswordLabel.text length] >0) {
        //判断这次密码是否是相同的
        if([self.passwordLabel.text isEqualToString:self.rePasswordLabel.text]){
            //存储注信息
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.usernameLabel.text forKey:@"registerName"];
            [userDefaults setObject:self.passwordLabel.text forKey:@"registerPassword"];
            HUD.labelText = @"正在注册";
            [HUD show:YES];
            [[XMPPAssistant shareXMPPAssistant] xmppUserRegister:^(XMPPResultType type) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    HUD.mode = MBProgressHUDModeText;
                    if (type == XMPPResultTypeRegisterSuccess) {
                        HUD.labelText = @"注册成功!";
                        HUD.detailsLabelText = @"现在可以用已注册的账号登录。";
                        [self performSelector:@selector(back:) withObject:self afterDelay:1.0];
                    }else if (type == XMPPResultTypeNetErr){
                        HUD.detailsLabelText = @"请检查网络或服务器地址。";
                        HUD.labelText = @"连接错误";
                    }else {
                        HUD.labelText = @"注册失败";
                    }
                    [HUD hide:YES afterDelay:2.0];
                });
            }];
        }else{
            self.passwordLabel.text = @"";
            self.rePasswordLabel.text = @"";
            [self.passwordLabel becomeFirstResponder];
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = @"两次密码不一致,请重新填写。";
            [HUD show:YES];
            [HUD hide:YES afterDelay:2.0];
            [self showInputInforHint];
        }
    }else{
        [self showInputInforHint];
    }
}

// 调整信息输入提示
- (void)showInputInforHint{
    self.usernameHintimageView.hidden = YES;
    self.passwordHintImageView.hidden = YES;
    self.repasswordHintImageView.hidden = YES;
    
    if ([self.usernameLabel.text length] <1) {
        self.usernameHintimageView.hidden = NO;
    }
    if ([self.passwordLabel.text length] <1) {
        self.passwordHintImageView.hidden = NO;
    }
    if ([self.rePasswordLabel.text length] <1) {
        self.repasswordHintImageView.hidden = NO;
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

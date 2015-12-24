//
//  CEAddFriendContorller.m
//  CoarseExchange
//
//  Created by stoull on 12/23/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEAddFriendContorller.h"
#import "CEConnectModel.h"
#import "XMPPAssistant.h"
#import "XMPP.h"
#import "UITextField+WF.h"
#import "MBProgressHUD.h"

@interface CEAddFriendContorller ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addFriendsTextLabel;

@end

@implementation CEAddFriendContorller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"添加好友";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *usr = textField.text;
    CELog(@"要添加的好友账号： %@",usr);
    
    // 判断这个账号是否合法
//    if (![textField isTelphoneNum]) {
//        [self showAlert:@"账号不合法"];
//    }
    
    // 判断是否添加自己
    NSString *currentUser = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation][@"username"];
    if ([usr isEqualToString:currentUser]) {
        [self showAlert:@"不能添加自己为好友"];
        return YES;
    }
    
    NSString *host = [[CEConnectModel shareCEConnectModel] getCurrentHostDicInformation][@"host"];
    NSString *JID = [NSString stringWithFormat:@"%@@%@",usr,host];
    XMPPJID *friendJid = [XMPPJID jidWithString:JID];
    
    // 判断好友是否存在
    if ([[XMPPAssistant shareXMPPAssistant].rosterStorage userExistsWithJID:friendJid xmppStream:[XMPPAssistant shareXMPPAssistant].xmppStream]) {
        [self showAlert:@"当前好友已存在"];
        return YES;
    }
    
    // 发送添加好友请求，xmpp订阅
    [[XMPPAssistant shareXMPPAssistant].roster subscribePresenceToUser:friendJid];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"正添加好友！";
    [HUD show:YES];
    [HUD hide:YES afterDelay:2.0];
    
    return YES;
}

- (IBAction)addClick:(id)sender {
    NSString *usr = self.addFriendsTextLabel.text;
    CELog(@"要添加的好友账号： %@",usr);
    
    // 判断这个账号是否合法
    //    if (![textField isTelphoneNum]) {
    //        [self showAlert:@"账号不合法"];
    //    }
    
    // 判断是否添加自己
    NSString *currentUser = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation][@"username"];
    if ([usr isEqualToString:currentUser]) {
        [self showAlert:@"不能添加自己为好友"];
        return ;
    }
    
    NSString *host = [[CEConnectModel shareCEConnectModel] getCurrentHostDicInformation][@"host"];
    NSString *JID = [NSString stringWithFormat:@"%@@%@",usr,host];
    XMPPJID *friendJid = [XMPPJID jidWithString:JID];
    
    // 判断好友是否存在
    if ([[XMPPAssistant shareXMPPAssistant].rosterStorage userExistsWithJID:friendJid xmppStream:[XMPPAssistant shareXMPPAssistant].xmppStream]) {
        [self showAlert:@"当前好友已存在"];
        return ;
    }
    
    // 发送添加好友请求，xmpp订阅
    [[XMPPAssistant shareXMPPAssistant].roster subscribePresenceToUser:friendJid];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"已发送好友请求！";
    [HUD show:YES];
    [HUD hide:YES afterDelay:2.0];
}



- (void)showAlert:(NSString *)msg
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];

    [alertView addAction:confirmAction];

    [self presentViewController:alertView animated:YES completion:nil];
}
@end

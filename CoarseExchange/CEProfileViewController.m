//
//  CEProfileViewController.m
//  CoarseExchange
//
//  Created by stoull on 12/22/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "XMPPAssistant.h"
#import "CEConnectModel.h"

@interface CEProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *headerIcon;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *CENumberLabel;

@end

@implementation CEProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人设置";
    
    // xmpp 获取个人信息
    XMPPvCardTemp *myVCard = [XMPPAssistant shareXMPPAssistant].vCard.myvCardTemp;
    
    // 设置图像
    if (myVCard.photo) {
        [self.headerIcon setBackgroundImage:[UIImage imageWithData:myVCard.photo] forState:UIControlStateNormal];
    }
    
    // 设置昵称以及号码
    self.nickNameLabel.text = myVCard.nickname;
    NSDictionary *userInfor = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation];
    self.CENumberLabel.text = userInfor[@"username"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOut:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //WXLog(@"%@",[UIApplication sharedApplication].keyWindow);
    
#pragma -mark 关闭xmpp服务，并将该单例回收(不然登录新的用户还用xmppStream，coreData会冲突)
    XMPPAssistant *assist = [XMPPAssistant shareXMPPAssistant];
    [assist teardownXmpp];
    assist = nil;
    
    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
    [[XMPPAssistant shareXMPPAssistant] logOutXmppJID];
}


@end

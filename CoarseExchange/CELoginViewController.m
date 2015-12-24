//
//  ViewController.m
//  CoarseExchange
//
//  Created by stoull on 12/2/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "Reachability.h"
#import "CELoginViewController.h"
#import "AppDelegate.h"
#import "CEConnectModel.h"
#import "UIImage+UICycle.h"
#import "MBProgressHUD.h"
#import "XMPPAssistant.h"
#import "CERegisterController.h"
#import "CETransition.h"

static NSString *cellIdentify = @"accountCell";
@interface CELoginViewController ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}
@property (nonatomic, strong) AppDelegate *CEDelegate;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UILabel *userNameErrorHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordErrorHintLabel;

@property (weak, nonatomic) IBOutlet UIButton *remeberPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *autoLogoButton;

@property (nonatomic, strong) UIButton *downSelectButton;
@property (nonatomic, strong) UITableView *selectAccountTableView;


@property (nonatomic, strong) CEConnectModel *connectModel;

@end

@implementation CELoginViewController

-(AppDelegate *)CEDelegate{
    if (!_CEDelegate) {
        _CEDelegate = [UIApplication sharedApplication].delegate;
    }
    return _CEDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.connectModel = [CEConnectModel shareCEConnectModel];
    // 显示输入用户名和密码时输入框后面的取消按钮
    self.userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // 填充上一次登录成功后的用户名和密码
    NSDictionary *lastAccountDic = [self.connectModel getCurrentAccountDicInformation];
    self.userNameTextField.text = [lastAccountDic objectForKey:@"username"];
    NSString *password = [lastAccountDic objectForKey:@"password"];
    if ([password isEqualToString:@" "]) {
        self.passwordTextField.text = nil;
    }else{
        self.passwordTextField.text = password;
    }
    
    // 判断是否是记住密码以及自动登录
    self.remeberPasswordButton.selected = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemeberPassword"];
    BOOL isAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoLogin"];
    self.autoLogoButton.selected = isAutoLogin;
    if (isAutoLogin) {
        [self loginClick:nil];
    }
    
    // 如果登录过多个账号，则显示多个账号选择按钮，用户根据历史记录选择账号
    NSArray *accountArray = [self.connectModel getAccountArray];
    if ([accountArray count] > 1) {
        UIButton *downSelectButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [downSelectButton addTarget:self action:@selector(choiceAccount:) forControlEvents:UIControlEventTouchUpInside];
        [downSelectButton setBackgroundImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
        self.downSelectButton = downSelectButton;
        self.userNameTextField.leftView = downSelectButton;
        self.userNameTextField.leftViewMode = UITextFieldViewModeAlways;
        
        self.passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    }

    
    self.userNameErrorHintLabel.hidden = YES;
    self.passwordErrorHintLabel.hidden = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

// 下拉选择账号
- (void)choiceAccount:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        CGRect userNameLabelFrame = self.userNameTextField.frame;
        CGFloat accountTableViewHeight = (50 * [[self.connectModel getAccountArray] count]);
        UITableView *accountTableView = [[UITableView alloc] initWithFrame:CGRectMake(userNameLabelFrame.origin.x, userNameLabelFrame.origin.y + userNameLabelFrame.size.height, userNameLabelFrame.size.width, accountTableViewHeight) style:UITableViewStylePlain];
        accountTableView.backgroundColor = [UIColor clearColor];
        
        accountTableView.dataSource = self;
        accountTableView.delegate = self;
        self.selectAccountTableView = accountTableView;
        [self.view addSubview:accountTableView];
        [sender setBackgroundImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
    }else{
        [self.selectAccountTableView removeFromSuperview];
        [sender setBackgroundImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
    }

}

#pragma -mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.connectModel getAccountArray] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentify];
    }
    
    NSArray *accountArray = [self.connectModel getAccountArray];
    NSDictionary *accountDic = accountArray[indexPath.row];
    NSString *userName = [accountDic objectForKey:@"username"];
    UIImage *headerImage = [UIImage imageNamed:@"002"];
    headerImage = [UIImage scaleToSize:headerImage size:CGSizeMake(35, 35)];
    cell.imageView.image = [UIImage circleImageWithImage:headerImage borderWidth:.0 boraderColor:[UIColor clearColor]];
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    deleteButton.tag = indexPath.row;
    [deleteButton addTarget:self action:@selector(deleteAccount:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = deleteButton;
    cell.textLabel.text = userName;
    return cell;
}


#pragma -mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *accountArray = [self.connectModel getAccountArray];
    NSDictionary *accountDic = accountArray[indexPath.row];
    self.userNameTextField.text = [accountDic objectForKey:@"username"];
    NSString *password = [accountDic objectForKey:@"password"];
    if ([password isEqualToString:@" "]) {
        self.passwordTextField.text = nil;
    }else{
        self.passwordTextField.text = password;
    }
    [self resetAccountSelectButton];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)deleteAccount:(UIButton *)button
{
    NSLog(@"button_tag : %ld",button.tag);
    NSArray *accountArray = [self.connectModel getAccountArray];
    NSDictionary *accountDic = accountArray[button.tag];
    [self.connectModel removeAccountByUserName:accountDic[@"username"]];
    [self.selectAccountTableView reloadData];
}


// 记住密码按钮
- (IBAction)remeberPassword:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:@"isRemeberPassword"];
}

// 自动登录按钮
- (IBAction)logoAuto:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:@"isAutoLogin"];
}


#pragma -mark 登录动作
- (IBAction)loginClick:(id)sender {
    [self resetAccountSelectButton];
    if (![self isExistenceNetwork]) {
        NSLog(@"联不上网络！！");
        return;
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    NSString *username = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([username length] > 0) {
        self.userNameErrorHintLabel.hidden = YES;
    }else {
        self.userNameErrorHintLabel.hidden = NO;
    }
    
    if ([password length] > 0 && ![password isEqualToString:@" "]) {
        self.passwordErrorHintLabel.hidden = YES;
    }else {
        self.passwordErrorHintLabel.hidden = NO;
    }
    
    if ([username length] > 0 && [password length] > 0 && ![password isEqualToString:@" "]) {
        // 设置用户信息
        NSString *currentHost = [self.connectModel getCurrentHostDicInformation][@"host"];
        // 是否设置服务地址
        if (!currentHost) {
            HUD.labelText = @"请设置服务地址！";
            HUD.mode = MBProgressHUDModeText;
            [HUD show:YES];
            [HUD hide:YES afterDelay:2.0];
            return;
        }
        NSDictionary *jidDic = @{@"password" : password,
                                 @"username" : username,
                                 @"host" : currentHost };
        [[XMPPAssistant shareXMPPAssistant] setJIDInforDic:jidDic];
        
        HUD.labelText = @"正在登录";
        [HUD show:YES];
        [[XMPPAssistant shareXMPPAssistant] xmppUserLogin:^(XMPPResultType type) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(type == XMPPResultTypeLoginSuccess){
                    HUD.mode = MBProgressHUDModeText;
                    HUD.labelText = @"登录成功";
                    [HUD hide:YES];
                    // 如果登录成功，则根据是否记住密码存入用户信息
                    if (self.remeberPasswordButton.selected) {
                        [self.connectModel addUserAccountWithUserName:username andPassword:password];
                    }else{
                        // 没有记住密码，密码就存入空格
                        [self.connectModel addUserAccountWithUserName:username andPassword:@" "];
                    }
                    // 登录成功后推出主界面
                    [self performSegueWithIdentifier:@"lonInSuccessfulSegue" sender:self];
                }else if (type == XMPPResultTypeNetErr)
                {
                    HUD.detailsLabelText = @"请检查网络或服务器地址。";
                    HUD.labelText = @"连接错误";
                }else{
                    HUD.labelText = @"密码错误或无此用户！";
                }
                [HUD hide:YES afterDelay:2.0];
            });
        }];
    }else {
        NSLog(@"用户名和密码不完整！");
    }
}


- (void)enterTheMainView{
    
}

#pragma -mark 注册动作
- (IBAction)registerJID:(id)sender {
    // 自定义转场
    UIViewController *destinatinController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"registerViewController"];
    destinatinController.modalPresentationStyle = UIModalPresentationCustom;
    destinatinController.transitioningDelegate = [CETransition shareCETransition];
    [self presentViewController:destinatinController animated:YES completion:nil];
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
    [self resetAccountSelectButton];
}


// 下拉选择账号的时候，关闭下拉并将指示按钮图片复原
- (void)resetAccountSelectButton
{
    [self.selectAccountTableView removeFromSuperview];
    self.downSelectButton.selected = NO;
    [self.downSelectButton setBackgroundImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
}


//监测网路
- (BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"]; //demo.linkwe.cn 经常挂
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=FALSE;
            //NSLog(@"没有网络");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=TRUE;
            //NSLog(@"正在使用3G网络");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=TRUE;
            //NSLog(@"正在使用wifi网络");
            break;
    }
    if (!isExistenceNetwork) {
        NSLog(@"网络已断开!");
    }
    return isExistenceNetwork;
}
@end

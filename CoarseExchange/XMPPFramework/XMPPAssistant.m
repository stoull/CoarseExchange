//
//  XMPPAssistant.m
//  CoarseExchange
//
//  Created by stoull on 12/18/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "XMPPAssistant.h"
#import "CEConnectModel.h"
@interface XMPPAssistant()
{
    XMPPReconnect *_reconnect;// 自动连接模块
    
    XMPPvCardCoreDataStorage *_vCardStorage;//电子名片的数据存储
    
    XMPPvCardAvatarModule *_avatar;//头像模块
    
    
    XMPPRoster *_roster;//花名册模块
    
    XMPPMessageArchiving *_msgArchiving;//聊天模块
}

@property (nonatomic, strong)NSDictionary *JIDInforDic;

// 区分登录和注册动作
@property (nonatomic, assign)BOOL isRegistJID;
@property (nonatomic, strong) XMPPReslutBlock resutltBlock;

@end


@implementation XMPPAssistant
singleton_implementation(XMPPAssistant)

-(void)setJIDInforDic:(NSDictionary *)JIDInforDic
{
    if (JIDInforDic) {
        _JIDInforDic = JIDInforDic;
    }else{
        NSString *currentHost = [CEConnectModel getCurrentHostDicInformation][@"host"];
        NSDictionary *currentAccount = [CEConnectModel getCurrentAccountDicInformation];
        NSDictionary *jidDic = @{@"password" : currentAccount[@"password"],
                                 @"username" : currentAccount[@"username"],
                                 @"host" : currentHost };
        _JIDInforDic = jidDic;
    }
}

- (void)setupStream {
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
    }
    
    if (!_isRegistJID) {
        
#warning 每一个模块添加后都要激活
        
        // 添加花名册模块
        _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
        _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
        //激活
        [_roster activate:_xmppStream];
        
        // 添加电子名片模块【获取好友列表】
        _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
        [_vCard activate:_xmppStream];
    }

    // 添加聊天模块
    _msgStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgStorage];
    [_msgArchiving activate:_xmppStream];
    
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}


#pragma mark 释放xmppStream相关的资源
-(void)teardownXmpp{
    
    // 移除代理
    [_xmppStream removeDelegate:self];
    
    // 停止模块
    [_reconnect deactivate];
    [_vCard deactivate];
    [_avatar deactivate];
    [_roster deactivate];
    
    // 断开连接
    [_xmppStream disconnect];
    
    // 清空资源
    _reconnect = nil;
    _vCard = nil;
    _vCardStorage = nil;
    _avatar = nil;
    _roster = nil;
    _rosterStorage = nil;
    _xmppStream = nil;
    
}

#pragma -mark 注册用户
- (void)xmppUserRegister:(XMPPReslutBlock)resultBlock{
    // 将传过来的block存起来
    _resutltBlock = resultBlock;
    _isRegistJID = YES;
    // 如果先建立的连接则要先断开
    [_xmppStream disconnect];
    
    [self connectToHost];
    
}
#pragma -mark 用户登录
- (void)xmppUserLogin:(XMPPReslutBlock)resultBlock{
    _resutltBlock = resultBlock;
    _isRegistJID = NO;
    [_xmppStream disconnect];
    [self connectToHost];
}

#pragma -mark 建立连接
- (void)connectToHost{
    // 1.设置XMPPStream
    [self setupStream];
    
    // 2. 设置用户名，密码，及服务器等 XMPPStream信息
    if (_isRegistJID) {
        // 发送注册用户名信息
        NSString *registUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"registerName"];
        NSDictionary *hostDic = [[CEConnectModel shareCEConnectModel] getCurrentHostDicInformation];
        [_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",registUserName,hostDic[@"host"]]]];
    }else{
        [_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",_JIDInforDic[@"username"],_JIDInforDic[@"host"]]]];
    }
    [_xmppStream setHostName:_JIDInforDic[@"host"]];
    
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        CELog(@"连接错误： %@",error.localizedDescription);
    }else {
        CELog(@"连接成功！");
    }
    
}

#pragma -mark 用户退出登录
- (void)logOutXmppJID{
    // 1. 发送离线状态
    [self goOffline];
    // 2. XMPPStream断开连接
    [_xmppStream disconnect];
    
}


#pragma -mark 发送上线离线通知
- (void)sendOnlineToHost {
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
}

#pragma -mark XMPPStreamDelegate代理方法
#pragma -mark 连接到服务器的结果
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error = nil;
    // 1. 验证密码
    if (_isRegistJID) {
        NSString *registPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"registerPassword"];
        [_xmppStream registerWithPassword:registPassword error:&error];
        if (error) {
          CELog(@"注册出现错误：%@",error.localizedDescription);   
        }
    }else{
        [_xmppStream authenticateWithPassword:_JIDInforDic[@"password"] error:&error];
        if (error) {
            CELog(@"登录身份验证错误：%@", error.localizedDescription);
        }
    }
}
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    // 如果有错误，代表连接失败
    
    // 如果没有错误，表示正常的断开连接(人为断开连接)
    if(error && _resutltBlock){
        _resutltBlock(XMPPResultTypeNetErr);
    }
    CELog(@"与主机断开连接 %@",error);
    
}

#pragma -mark 授权登录结果
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self sendOnlineToHost];
    // 回调代码块
    if (_resutltBlock) {
        _resutltBlock(XMPPResultTypeLoginSuccess);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    CELog(@"验证失败：%@", error);
    if (_resutltBlock) {
        _resutltBlock(XMPPResultTypeLoginFailure);
    }
}

#pragma -mark 注册结果
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    if (_resutltBlock) {
        _resutltBlock(XMPPResultTypeRegisterSuccess);
    }
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    if (_resutltBlock) {
        _resutltBlock(XMPPResultTypeRegisterFailure);
    }
}

-(void)dealloc{
    [self teardownXmpp];
}

@end

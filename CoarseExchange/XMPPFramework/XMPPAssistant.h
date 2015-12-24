//
//  XMPPAssistant.h
//  CoarseExchange
//
//  Created by stoull on 12/18/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "CCSSingleton.h"
typedef enum {
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoginFailure,//登录失败
    XMPPResultTypeNetErr,//网络不给力
    XMPPResultTypeRegisterSuccess,//注册成功
    XMPPResultTypeRegisterFailure//注册失败
}XMPPResultType;

typedef  void (^XMPPReslutBlock)(XMPPResultType type);

@interface XMPPAssistant : NSObject
singleton_interface(XMPPAssistant)
@property (nonatomic, strong)XMPPvCardTempModule *vCard;//电子名片
@property (nonatomic, strong)XMPPRosterCoreDataStorage *rosterStorage;//花名册数据存储
@property (nonatomic, strong)XMPPRoster *roster;//花名册模块
@property (nonatomic, strong,readonly)XMPPMessageArchivingCoreDataStorage *msgStorage;//聊天的数据存储

-(void)setJIDInforDic:(NSDictionary *)JIDInforDic;

@property (readonly, strong, nonatomic) XMPPStream *xmppStream;

// 用户退出登录
- (void)logOutXmppJID;


// 用户登录
- (void)xmppUserLogin:(XMPPReslutBlock)resultBlock;

// 用户注册
- (void)xmppUserRegister:(XMPPReslutBlock)resultBlock;

- (void)teardownXmpp;
@end

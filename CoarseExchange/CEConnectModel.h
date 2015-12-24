//
//  CEConnectService.h
//  CoarseExchange
//
//  Created by stoull on 12/8/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCSSingleton.h"

@interface CEConnectModel : NSObject<NSCoding>
singleton_interface(CEConnectModel)
@property (nonatomic, copy) NSString *archiverPath;

@property (nonatomic, strong) NSDictionary *currentAccountDic;
@property (nonatomic, strong) NSDictionary *currentHostDic;

@property (nonatomic, strong) NSMutableArray *accountArray;
@property (nonatomic, strong) NSMutableArray *hostArray;

/**
 *  将一个站点添加入模型，并将该站点设为当前站点
 *
 *  @param host 站点
 *  @param descripte 站点名
 */
+ (void)addToCurrentHost:(NSString *)host andDescripte:(NSString *)descripte;
- (void)addToCurrentHost:(NSString *)host andDescripte:(NSString *)descripte;

+ (void)setCurrentHost:(NSDictionary *)hostDic;
- (void)setCurrentHost:(NSDictionary *)hostDic;

/**
 *  获得当前的站点信息
 *
 *  @return 包含当前站点及站点名的字典key分别是host和descripte
 */
+ (NSDictionary *)getCurrentHostDicInformation;
- (NSDictionary *)getCurrentHostDicInformation;

+ (void)deleteHost:(NSString *)host;
- (void)deleteHost:(NSString *)host;

/**
 *  将一个用户名及密码添加入模型，并将该用户设为当前用户，并置于accountArray第一位，对已存的用户作同样的处理
 *
 *  @param username 用户名
 *  @param password 用户密码
 */
+ (void)addUserAccountWithUserName:(NSString *)username andPassword:(NSString *)password;
- (void)addUserAccountWithUserName:(NSString *)username andPassword:(NSString *)password;
/**
 *  获得当前的用户名及密码
 *
 *  @return 包含当前用户名及密码的字典key分别是username和password
 */
+ (NSDictionary *)getCurrentAccountDicInformation;
- (NSDictionary *)getCurrentAccountDicInformation;

/**
 *  移除这个用户的登录资料
 *
 *  @param username 用户名
 */
- (void)removeAccountByUserName:(NSString *)username;

+ (NSArray *)getAccountArray;
+ (NSArray *)getHostArray;
- (NSArray *)getAccountArray;
- (NSArray *)getHostArray;


@end

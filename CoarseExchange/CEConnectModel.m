//
//  CEConnectService.m
//  CoarseExchange
//
//  Created by stoull on 12/8/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEConnectModel.h"

static NSString *archiveFileName = @"ConnectModelInfor";

@interface CEConnectModel()
@property (nonatomic, strong) NSFileManager *mgr;

@end

@implementation CEConnectModel
singleton_implementation(CEConnectModel)
-(NSFileManager *)mgr
{
    if (!_mgr) {
        _mgr = [NSFileManager defaultManager];
    }
    return _mgr;
}
-(NSMutableArray *)hostArray{
    if (!_hostArray) {
        _hostArray = [NSMutableArray array];
    }
    return _hostArray;
}
-(NSMutableArray *)accountArray
{
    if (!_accountArray) {
        _accountArray = [NSMutableArray array];
    }
    return _accountArray;
}

-(NSString *)archiverPath
{
    if (!_archiverPath) {
        NSString *archiverPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _archiverPath = [archiverPath stringByAppendingPathComponent:archiveFileName];
        
        NSLog(@" ??XX : %@",archiverPath);
        
        if (![self.mgr fileExistsAtPath:archiverPath]) {
            [self.mgr createFileAtPath:archiverPath contents:nil attributes:nil];
        }
    }
    return _archiverPath;
}

////////////////////////////////////////////////////////////////////////
+ (void)addToCurrentHost:(NSString *)host andDescripte:(NSString *)descripte
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    [model addToCurrentHost:host andDescripte:descripte];
}
- (void)addToCurrentHost:(NSString *)host andDescripte:(NSString *)descripte
{
    if ([host length] > 0 && [descripte length] > 0) {
        _currentHostDic = @{@"descripte" : descripte, @"host" : host};
        if ([self.hostArray count] > 0) {
            BOOL isHaveSameHost = NO;
            for (NSDictionary *oldHostDic in self.hostArray){
                NSString *oldHost = oldHostDic[@"host"];
                if ([oldHost isEqualToString:host]) {
                    isHaveSameHost = YES;
                    [self.hostArray removeObject:oldHostDic];
                    [self.hostArray insertObject:@{@"host" : host,
                                                   @"descripte" : descripte} atIndex:0];
                    break;
                }
            }
            if (!isHaveSameHost) {
                [self.hostArray insertObject:@{@"host" : host,
                                               @"descripte" : descripte} atIndex:0];
            }
        }else{
            [self.hostArray addObject:@{@"host" : host,
                                        @"descripte" : descripte}];
        }
        [self save];
    }
}

////////////////////////////////////////////////////////////////////////
- (void)setCurrentHost:(NSDictionary *)hostDic
{
    if (hostDic != nil) {
        _currentHostDic = hostDic;
        [self save];
    }
}
+ (void)setCurrentHost:(NSDictionary *)hostDic
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    [model setCurrentHost:hostDic];
}


////////////////////////////////////////////////////////////////////////
+ (NSDictionary *)getCurrentHostDicInformation
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    return [model getCurrentHostDicInformation];
}
- (NSDictionary *)getCurrentHostDicInformation
{
    CEConnectModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
    return model.currentHostDic;
}

////////////////////////////////////////////////////////////////////////
+ (void)addUserAccountWithUserName:(NSString *)username andPassword:(NSString *)password
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    [model addUserAccountWithUserName:username andPassword:password];
}
- (void)addUserAccountWithUserName:(NSString *)username andPassword:(NSString *)password
{
    if ([username length] > 0 && [password length] > 0) {
        _currentAccountDic = @{@"username" : username ,@"password" : password};
        if ([self.accountArray count] > 0) {
            BOOL isHaveSameAccount = NO;
            for (NSDictionary *oldAccountDic in self.accountArray){
                NSString *oldUsername = oldAccountDic[@"username"];
                if ([oldUsername isEqualToString:username]) {
                    isHaveSameAccount = YES;
                    [self.accountArray removeObject:oldAccountDic];
                    [self.accountArray insertObject:@{@"username" : username,
                                                      @"password" : password} atIndex:0];
                    break;
                }
            }
            if (!isHaveSameAccount) {
                [self.accountArray insertObject:@{@"username" : username,
                                                  @"password" : password} atIndex:0];
            }
        }else{
            [self.accountArray addObject:@{@"username" : username,
                                        @"password" : password}];
        }
        [self save];
    }
}

////////////////////////////////////////////////////////////////////////
+ (NSDictionary *)getCurrentAccountDicInformation
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    return [model getCurrentAccountDicInformation];
}
- (NSDictionary *)getCurrentAccountDicInformation
{
    CEConnectModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
    return model.currentAccountDic;
}

////////////////////////////////////////////////////////////////////////
- (NSArray *)getAccountArray
{
    CEConnectModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
    return model.accountArray;
}

- (NSArray *)getHostArray
{
    CEConnectModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
    return model.hostArray;
}

+ (NSArray *)getAccountArray
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    return [model getAccountArray];
}

+ (NSArray *)getHostArray
{
    CEConnectModel *model = [CEConnectModel shareCEConnectModel];
    return [model getHostArray];
}

// 归档所有数据
- (void)save
{
    if ([NSKeyedArchiver archiveRootObject:self toFile:self.archiverPath])
    {
        NSLog(@" successful !");
    }else{
        NSLog(@" failed !");
    }
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_currentAccountDic forKey:@"currentAcountDic"];
    [aCoder encodeObject:_currentHostDic forKey:@"currentHostDic"];
    [aCoder encodeObject:_accountArray forKey:@"accountArray"];
    [aCoder encodeObject:_hostArray forKey:@"hostArray"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _currentAccountDic = [aDecoder decodeObjectForKey:@"currentAcountDic"];
        _currentHostDic = [aDecoder decodeObjectForKey:@"currentHostDic"];
        _accountArray = [aDecoder decodeObjectForKey:@"accountArray"];
        _hostArray = [aDecoder decodeObjectForKey:@"hostArray"];
    }
    return self;
}
@end

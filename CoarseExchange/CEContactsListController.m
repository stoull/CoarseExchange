//
//  CEContactsListController.m
//  CoarseExchange
//
//  Created by stoull on 12/22/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEContactsListController.h"
#import "CEFriendTableViewCell.h"
#import "XMPPAssistant.h"
#import "CEConnectModel.h"
#import "CEChatViewController.h"
#import "UIImage+UICycle.h"

@interface CEContactsListController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultsController;
}
@property (nonatomic, strong) NSArray *friendsArray;


@end

@implementation CEContactsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"好友列表";
    // 从数据里加载好友列表显示
    [self loadFriends2];
}

- (void)loadFriends2{
    // 1.上下文【文联到XMPPRoster.sqlite】
    NSManagedObjectContext *context = [XMPPAssistant shareXMPPAssistant].rosterStorage.mainThreadManagedObjectContext;
    
    // 2.FetchRequest[查那张表]
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 3.设置过虑和排序
    NSString *username = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation][@"username"];
    NSString *host = [[CEConnectModel shareCEConnectModel] getCurrentHostDicInformation][@"host"];
    NSString *JID = [NSString stringWithFormat:@"%@@%@",username,host];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",JID];
    fetchRequest.predicate = pre;
    
    // 4. 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    
    // 5.执行请求获取数据
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _resultsController.delegate = self;
    
    NSError *err = nil;
    [_resultsController performFetch:&err];
    
    NSLog(@" _results　%ld",_resultsController.fetchedObjects.count);
    
    if (err) {
        CELog(@"%@",err);
    }
}

#pragma -mark NSFetchedResultsControllerDelegate 当数据内容发生改变后，会调用这个方法
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    CELog(@"数据发生变化，更新数据");
    [self.tableView reloadData];
}


// 第一种直接获取数据
- (void)loadFriends{
    // 使用CoreData获得数据
    // 1.上下文【文联到XMPPRoster.sqlite】
    NSManagedObjectContext *context = [XMPPAssistant shareXMPPAssistant].rosterStorage.mainThreadManagedObjectContext;
    
    // 2.FetchRequest[查那张表]
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 3.设置过虑和排序
    NSString *username = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation][@"username"];
    NSString *host = [[CEConnectModel shareCEConnectModel] getCurrentHostDicInformation][@"host"];
    NSString *JID = [NSString stringWithFormat:@"%@@%@",username,host];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",JID];
    fetchRequest.predicate = pre;
    
    // 4. 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    
    // 5.执行请求获取数据
    NSError *error = nil;
    self.friendsArray = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@" friendsArrayCount : %ld",self.friendsArray.count);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.friendsArray.count;
    return _resultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifer = @"contactCell";
    CEFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    
    // 获取对应的好友
//        XMPPUserCoreDataStorageObject *friend = self.friendsArray[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = _resultsController.fetchedObjects[indexPath.row];
    
    // 设置头像
    UIImage *headerImage = [UIImage imageNamed:@"002"];
    
    switch ([friend.sectionNum intValue]) {
        case 0:
            cell.stateLabel.text = @"在线";
            break;
        case 1:
            cell.stateLabel.text = @"离开";
            break;
        case 2:
            cell.stateLabel.text = @"离线";
            headerImage = [UIImage grayImage:headerImage];
            break;
        default:
            break;
    }

    cell.iconImageView.image = [UIImage circleImageWithImage:headerImage borderWidth:0.0 boraderColor:[UIColor clearColor]];
    NSString *name = [[friend.jidStr componentsSeparatedByString:@"@"] firstObject];
    cell.nameLabel.text = name;
    
//    cell.nameLabel.text = @"呼啦啦";
    cell.signLabel.text = @"从村子的这边呼啦啦到那边";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *friend = _resultsController.fetchedObjects[indexPath.row];
    
    [self performSegueWithIdentifier:@"puchChatContorller" sender:friend.jid];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destinationVC = segue.destinationViewController;
    if ([destinationVC isKindOfClass:[CEChatViewController class]]) {
        CEChatViewController *chatVC = destinationVC;
        chatVC.friendJid = sender;
    }
}

#pragma -mark 删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showAlert:indexPath];
    }
}

- (void)showAlert:(NSIndexPath *)indexPath
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"删除好友！" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        XMPPUserCoreDataStorageObject *friend = _resultsController.fetchedObjects[indexPath.row];
        XMPPJID *needDeleteJID = friend.jid;
        CELog(@"删除好友 ：%@",needDeleteJID.user);
        [[XMPPAssistant shareXMPPAssistant].roster removeUser:needDeleteJID];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    [alertView addAction:cancelAction];
    [alertView addAction:confirmAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}
@end

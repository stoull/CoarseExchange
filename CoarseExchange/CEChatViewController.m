//
//  CEChatViewController.m
//  CoarseExchange
//
//  Created by stoull on 12/23/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEChatViewController.h"
#import "CEInputView.h"
#import "XMPPAssistant.h"
#import "XMPPFramework/XMPPFramework.h"
#import "CEConnectModel.h"

@interface CEChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultsContr;
}
@property (nonatomic, strong) NSLayoutConstraint *inputViewConstraint;//inputView底部约束
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) CEInputView *inputView;

@end

@implementation CEChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"对话：%@",self.friendJid.user];
    
    [self setUpView];
    
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 监听发送按钮
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage) name:CESentMessageNotification object:nil];
    
    //加载数据
    [self loadMsgs];
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    // 获取键盘高度
    CGRect kbEndFrm = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrm.size.height;
    
    // 如果是ios7以下的，当屏幕是横屏，键盘的高底是size.with
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        kbHeight = kbEndFrm.size.width;
    }
    
    self.inputViewConstraint.constant = kbHeight;
    
    // 表格滚动到底部
    [self scrollToTableBottom];
    
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    // 隐藏键盘的约束，距离底部一直为0
    self.inputViewConstraint.constant = 0;
}

- (void)scrollToTableBottom{
    if (_resultsContr.fetchedObjects.count > 1) {
        NSInteger lastRow = _resultsContr.fetchedObjects.count - 1;
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma -mark 获取消息
- (void)loadMsgs{
    // 上下文
    NSManagedObjectContext *context = [XMPPAssistant shareXMPPAssistant].msgStorage.mainThreadManagedObjectContext;
    // 请求对象
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤，排序
    // 1.当前登录用户的JID消息
    // 2.好友的JID消息
    NSString *username = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation][@"username"];
    NSString *host = [[CEConnectModel shareCEConnectModel] getCurrentHostDicInformation][@"host"];
    NSString *JID = [NSString stringWithFormat:@"%@@%@",username,host];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",JID,self.friendJid.bare];
    
    request.predicate = pre;
    
    // 时间升序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 查询
    _resultsContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    _resultsContr.delegate = self;
    
    [_resultsContr performFetch:&error];
    if (error) {
        CELog(@"%@",error);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultsContr.fetchedObjects.count;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
     if (!cell) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
     }

     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     // 获取聊天消息对象
     XMPPMessageArchiving_Message_CoreDataObject *msg = _resultsContr.fetchedObjects[indexPath.row];
     
     //显示消息
     if ([msg.outgoing boolValue]) {//自己发
         cell.textLabel.text = [NSString stringWithFormat:@"Me: %@",msg.body];
     }else{//别人发的
         cell.textLabel.text = [NSString stringWithFormat:@"Other: %@",msg.body];
     }
     
     
 // Configure the cell...
 
 return cell;
 }
 

- (void)setUpView{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
#warning 代码实现自动布局，要设置下面的属性为NO
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
    tableView.bounces = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 创建输入框
    CEInputView *inputView = [CEInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.inputTextView.delegate = self;
    self.inputView = inputView;
    [self.view addSubview:inputView];
    
    // 自动布局
    
    // 水平方向的约束
    NSDictionary *views = @{@"tableView" : tableView,
                            @"inputView" : inputView};
    
    // 1.tableView水平方向的约束
    NSArray *tableViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableViewHConstraints];
    
    // 2.inputView水平方向的约束
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    
    // 3.垂直方向的约束
    NSArray *vContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:vContraints];
    
    self.inputViewConstraint = [vContraints lastObject];
    
//    CELog(@"%@",vContraints);
}

#pragma -mark UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    NSString *text = textView.text;
    // 当有换行就等于按了send
    if ([text rangeOfString:@"\n"].length != 0) {
        [self sendMsgWithText:text];
        
        // 清空数据
        textView.text = nil;
    }
}

//点击发送按钮后的动作
- (void)sendMessage{
    NSString *text = self.inputView.inputTextView.text;
    if ([text length] > 0) {
        [self sendMsgWithText:text];
        // 清空数据
        self.inputView.inputTextView.text = nil;
    }
}
#pragma -mark 发送消息
- (void)sendMsgWithText:(NSString *)text{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    // 设置内容
    [msg addBody:text];
    [[XMPPAssistant shareXMPPAssistant].xmppStream sendElement:msg];
}

#pragma mark 刷新数据 ResultController的代理
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    // 刷新数据
    [self.tableView reloadData];
}

-(void)endEdit{
    [self.inputView.inputTextView resignFirstResponder];
}
@end

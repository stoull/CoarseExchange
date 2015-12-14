//
//  CEServiceAddressController.m
//  CoarseExchange
//
//  Created by stoull on 12/4/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEServiceAddressController.h"
#import "CEConnectModel.h"
#import "CEHostCell.h"
#import "CEEidtHostCell.h"

static NSString *cellIdentifer = @"serviceAddressCell";
static NSString *eidtCellIdentifer = @"editHostCell";
@interface CEServiceAddressController ()<UITableViewDataSource,UITableViewDelegate,editHostDelegate>
@property (weak, nonatomic) IBOutlet UITableView *serviceAddressTable;

@property (nonatomic, strong)CEConnectModel *connectModel;
@property (nonatomic, strong)NSDictionary *currentHostDic;

@property (nonatomic, assign) BOOL isAddHost;
@property (nonatomic, weak) CEEidtHostCell *editCell;
@end

@implementation CEServiceAddressController
-(CEConnectModel *)connectModel
{
    if (!_connectModel) {
        _connectModel = [CEConnectModel shareCEConnectModel];
    }
    return _connectModel;
}
-(NSDictionary *)currentHostDic
{
    if (!_currentHostDic) {
        _currentHostDic = [self.connectModel getCurrentHostDicInformation];
    }
    return _currentHostDic;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isAddHost) {
        return 2;
    }else {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isAddHost && section ==0) {
        return 1;
    }else{
        NSArray *hostArray = [CEConnectModel getHostArray];
        return [hostArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isAddHost && indexPath.section == 0) {
        CEEidtHostCell *eidtCell = [tableView dequeueReusableCellWithIdentifier:eidtCellIdentifer forIndexPath:indexPath];
        if (eidtCell == nil) {
            eidtCell = [[CEEidtHostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:eidtCellIdentifer];
        }
        eidtCell.hostLabel.text = nil;
        eidtCell.hostDescriptionLabel.text = nil;
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *hostCache = [def objectForKey:@"hostCache"];
        NSString *hostDescriptionCache = [def objectForKey:@"hostDescriptionCache"];
        if ([hostCache length] > 0) {
            eidtCell.hostLabel.text = hostCache;
        }
        if ([hostDescriptionCache length] > 0) {
            eidtCell.hostDescriptionLabel.text = hostDescriptionCache;
        }
        eidtCell.superTableViewelegate = self;
        self.editCell = eidtCell;
        eidtCell.selectionStyle = UITableViewCellSelectionStyleNone;
        eidtCell.identifierDescripteErrorLabel.hidden = YES;
        eidtCell.identifierHostErrorLabel.hidden = YES;
        return eidtCell;
    }else
    {
        CEHostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[CEHostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
        }
        NSArray *hostArray = [CEConnectModel getHostArray];
        NSDictionary *hostDic = hostArray[indexPath.row];
        NSString *host = hostDic[@"host"];
        cell.hostDescriptionLabel.text = host;
        cell.hostLabel.text = hostDic[@"descripte"];
        if ([self.currentHostDic[@"host"] isEqualToString:host]) {
            cell.selectedDot.hidden = NO;
        }else{
            cell.selectedDot.hidden = YES;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *hostArray = [CEConnectModel getHostArray];
    NSDictionary *getHostDic = hostArray[indexPath.row];
    self.currentHostDic = getHostDic;
    [self.connectModel setCurrentHost:getHostDic];
    [self.serviceAddressTable reloadData];
}

#pragma -mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isAddHost && indexPath.section == 0) {
        return 126;
    }else{
        return 80;
    }
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isAddHost) {
        if (section ==0) {
            return @"添加站点";
        }else{
            return @"最近使用站点";
        }
    }else {
        return @"最近使用站点";
    }
}

- (void)cancelAddHost
{
    self.isAddHost = false;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:@"hostCache"];
    [def removeObjectForKey:@"hostDescriptionCache"];
    [self.serviceAddressTable reloadData];
}
- (void)confirmAddHost
{
    self.editCell.identifierDescripteErrorLabel.hidden = YES;
    self.editCell.identifierHostErrorLabel.hidden = YES;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def removeObjectForKey:@"hostCache"];
    [def removeObjectForKey:@"hostDescriptionCache"];
    NSString *description = self.editCell.hostDescriptionLabel.text;
    NSString *host = self.editCell.hostLabel.text;
    if ([host length] > 0) {
        if ([description length] > 0) {
            [self.connectModel addToCurrentHost:host andDescripte:description];
            self.isAddHost = false;
            self.currentHostDic = @{@"host" : host, @"descripte": description};
            [self.serviceAddressTable reloadData];
        }else self.editCell.identifierDescripteErrorLabel.hidden = NO;
    }else self.editCell.identifierHostErrorLabel.hidden = NO;
}


- (IBAction)addTest:(id)sender {
    self.isAddHost = true;
    [self.serviceAddressTable reloadData];
}

-(void)dealloc
{
    // 存储已编辑但未取消，未验证的站点的站点
    if (self.isAddHost) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:self.editCell.hostLabel.text forKey:@"hostCache"];
        [def setObject:self.editCell.hostDescriptionLabel.text forKey:@"hostDescriptionCache"];
    }
}

@end

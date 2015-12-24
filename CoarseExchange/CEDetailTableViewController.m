//
//  CEDetailTableViewController.m
//  CoarseExchange
//
//  Created by stoull on 12/22/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEDetailTableViewController.h"
#import "XMPPvCardTemp.h"
#import "XMPPAssistant.h"
#import "CEConnectModel.h"

@interface CEDetailTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headerView;//头像
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;//昵称

@property (weak, nonatomic) IBOutlet UILabel *ceAccountNumLabel;//ce号码
@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel;//部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;//电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;//邮件


@end

@implementation CEDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    [self loadVCard];
    
}

#pragma -mark 获取个人资料
- (void)loadVCard{
    XMPPvCardTemp *myVcard = [XMPPAssistant shareXMPPAssistant].vCard.myvCardTemp;
    
    if (myVcard.photo) {
        self.headerView.image = [UIImage imageWithData:myVcard.photo];
    }
    self.nicknameLabel.text = myVcard.nickname;
    self.ceAccountNumLabel.text = [[CEConnectModel shareCEConnectModel] getCurrentAccountDicInformation][@"username"];
    self.orgnameLabel.text = myVcard.orgName;
    if ([myVcard.orgUnits count] >0) {
        self.orgunitLabel.text = myVcard.orgUnits[0];
    }
    self.titleLabel.text = myVcard.title;
#warning myVCard.telecomsAddresses 这个get方法，没有对电子名片的xml数据进行解析
    self.phoneLabel.text = myVcard.note;
    self.emailLabel.text = myVcard.mailer;
    
}

#pragma -mark 更新个人资料
-(void)editProfileViewControllerDidSave{
    // 保存
    //获取当前的电子名片信息
    XMPPvCardTemp *myvCard = [XMPPAssistant shareXMPPAssistant].vCard.myvCardTemp;
    
    // 图片
    myvCard.photo = UIImagePNGRepresentation(self.headerView.image);
    
    // 昵称
    myvCard.nickname = self.nicknameLabel.text;
    
    // 公司
    myvCard.orgName = self.orgnameLabel.text;
    
    // 部门
    if (self.orgunitLabel.text.length > 0) {
        myvCard.orgUnits = @[self.orgunitLabel.text];
    }
    
    
    // 职位
    myvCard.title = self.titleLabel.text;
    
    
    // 电话
    myvCard.note =  self.phoneLabel.text;
    
    // 邮件
    myvCard.mailer = self.emailLabel.text;
    
    
    //更新 这个方法内部会实现数据上传到服务，无需程序自己操作
    [[XMPPAssistant shareXMPPAssistant].vCard updateMyvCardTemp:myvCard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) { // 换头像
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"更换头像" message:@"选择图片来源" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *alertActionCamera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self sheetActionWithTag:1];
        }];
        
        UIAlertAction *alertActionPicker = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self sheetActionWithTag:2];
        }];
        UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:alertActionCamera];
        [alertController addAction:alertActionPicker];
        [alertController addAction:alertActionCancel];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
        
    }else { // 做别的事情
        
    }
}

- (void)sheetActionWithTag:(NSInteger)tag{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    // 设置代理
    imagePicker.delegate =self;
    
    // 设置允许编辑
    imagePicker.allowsEditing = YES;
    if (tag == 1) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else if (tag == 2){
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{
        
    }
    // 显示图片选择器
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma -mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    // 获取图片，设置图片
    self.headerView.image = info[UIImagePickerControllerEditedImage];
    // 隐藏当前模态窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 更新到服务器
    [self editProfileViewControllerDidSave];
}
@end

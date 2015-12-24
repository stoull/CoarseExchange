//
//  CEFriendTableViewCell.h
//  CoarseExchange
//
//  Created by stoull on 12/22/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

//
//  CEHostCell.h
//  CoarseExchange
//
//  Created by stoull on 12/12/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEHostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *hostDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedDot;

@property (weak, nonatomic) IBOutlet UIButton *deleteHostButton;
@property (nonatomic, strong) NSIndexPath *indexPath;


@end

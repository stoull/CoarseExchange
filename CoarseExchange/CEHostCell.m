//
//  CEHostCell.m
//  CoarseExchange
//
//  Created by stoull on 12/12/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEHostCell.h"

@implementation CEHostCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)deleteClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteHost" object:nil userInfo:@{@"indexPath" : self.indexPath}];
}

@end

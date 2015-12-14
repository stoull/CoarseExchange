//
//  CEEidtHostCell.m
//  CoarseExchange
//
//  Created by stoull on 12/12/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEEidtHostCell.h"
@interface CEEidtHostCell()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation CEEidtHostCell

- (IBAction)cancelAddHost:(id)sender {
    if ([(id)self.superTableViewelegate respondsToSelector:@selector(cancelAddHost)]) {
        [self.superTableViewelegate cancelAddHost];
    }
}
- (IBAction)confirmAddHost:(id)sender {
    if ([(id)self.superTableViewelegate respondsToSelector:@selector(confirmAddHost)]) {
        [self.superTableViewelegate confirmAddHost];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

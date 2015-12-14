//
//  CEEidtHostCell.h
//  CoarseExchange
//
//  Created by stoull on 12/12/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEServiceAddressController.h"
@protocol editHostDelegate
- (void)cancelAddHost;
- (void)confirmAddHost;
@end

@interface CEEidtHostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *hostDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *hostLabel;

@property (weak, nonatomic) IBOutlet UILabel *identifierDescripteErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *identifierHostErrorLabel;

@property (nonatomic, weak) id<editHostDelegate> superTableViewelegate;
@end

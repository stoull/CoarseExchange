//
//  CEChatViewController.h
//  CoarseExchange
//
//  Created by stoull on 12/23/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface CEChatViewController : UIViewController

@property (nonatomic, strong) XMPPJID *friendJid;

@end

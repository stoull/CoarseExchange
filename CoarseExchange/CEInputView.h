//
//  CEInputView.h
//  CoarseExchange
//
//  Created by stoull on 12/23/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEInputView : UIView
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

+(instancetype)inputView;

@end

//
//  CEInputView.m
//  CoarseExchange
//
//  Created by stoull on 12/23/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEInputView.h"
@interface CEInputView()


@end

@implementation CEInputView
- (IBAction)senderClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CESentMessageNotification object:nil];
}

+(instancetype)inputView{
    return [[[NSBundle mainBundle] loadNibNamed:@"CEInputView" owner:nil options:nil] lastObject];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

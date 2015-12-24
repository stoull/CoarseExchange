//
//  CEAnimatedTransitioning.m
//  CoarseExchange
//
//  Created by stoull on 12/21/15.
//  Copyright © 2015 AChang. All rights reserved.
//

CGFloat duration = 0.3;

#import "CEAnimatedTransitioning.h"
#import "UIView+Extension.h"

@implementation CEAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return duration;
}

// 进行自定义动画设置
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    if (self.isPresented) {
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.x = toView.width;
        [UIView animateWithDuration:duration animations:^{
            toView.x = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else{
        [UIView animateWithDuration:duration animations:^{
            UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
            fromView.x = -fromView.width;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end

//
//  CEPresentationController.m
//  CoarseExchange
//
//  Created by stoull on 12/21/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CEPresentationController.h"

@implementation CEPresentationController
//- (CGRect)frameOfPresentedViewInContainerView{
//    return CGRectMake(0, 50, self.containerView.frame.size.width, self.containerView.frame.size.height -100);
//}

- (void)presentationTransitionWillBegin{
    self.presentedView.frame = self.containerView.bounds;
    [self.containerView addSubview:self.presentedView];
    
}


- (void)presentationTransitionDidEnd:(BOOL)completed
{
    
}

- (void)dismissalTransitionWillBegin{
    self.presentedView.frame = self.containerView.bounds;
    [self.containerView addSubview:self.presentedView];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    [self.presentedView removeFromSuperview];
}

@end

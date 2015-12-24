//
//  CETransition.m
//  CoarseExchange
//
//  Created by stoull on 12/21/15.
//  Copyright © 2015 AChang. All rights reserved.
//

#import "CETransition.h"
#import "CEAnimatedTransitioning.h"
#import "CEPresentationController.h"

@implementation CETransition
singleton_implementation(CETransition)

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[CEPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    CEAnimatedTransitioning *animate = [[CEAnimatedTransitioning alloc] init];
    animate.isPresented = YES;
    return animate;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    CEAnimatedTransitioning *animate = [[CEAnimatedTransitioning alloc] init];
    animate.isPresented = NO;
    return animate;
}


@end

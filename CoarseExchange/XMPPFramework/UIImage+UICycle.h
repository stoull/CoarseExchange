//
//  UIImage+UICycle.h
//  CCMusicPlayer
//
//  Created by April on 6/16/15.
//  Copyright (c) 2015 gunzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UICycle)
/**
 * 根据指定图片的文件名获取一张圆形图片对象，并加边框
 * @param borderWidth
 * @param borderColor
 *
 */
+(UIImage *)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth boraderColor:(UIColor *)borderColor;

/** 改变一张图片的大小
 *
 * @param borderWidth
 * @param borderColor
 *
 */
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size;

+ (UIImage *)circleImageWithImage:(UIImage *)image borderWidth:(CGFloat)borderWidth boraderColor:(UIColor *)borderColor;

+ (UIImage *)grayImage:(UIImage *)sourceImage;
@end

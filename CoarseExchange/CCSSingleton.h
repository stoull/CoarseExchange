//
//  CCSSingleton.h
//  CCDeals
//
//  Created by April on 6/28/15.
//  Copyright (c) 2015 gunzi. All rights reserved.
//

#ifndef CCDeals_CCSSingleton_h
#define CCDeals_CCSSingleton_h


#define singleton_interface(className)\
+ (className *)share##className;

#define singleton_implementation(className) \
static className *_instance;\
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{\
if(_instance==nil)\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken,^{\
_instance = [super allocWithZone:zone];\
});\
}\
return _instance;\
}\
+ (className *)share##className\
{\
if (!_instance)\
{\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken,^{\
_instance = [[self alloc]init];\
});\
}\
return _instance;\
}\
-(instancetype)copyWithZone:(NSZone *)zone\
{\
    return self;\
}

#endif

//
//  ZGWorkflowCell.m
//  瀑布流
//
//  Created by Gao on 16/1/26.
//  Copyright © 2016年 Gao. All rights reserved.
//

// 颜色
#define ZGColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 随机色
#define ZGRandomColor ZGColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256)) //传入0到256之间随机数

#import "ZGWorkflowCell.h"

@implementation ZGWorkflowCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
//        self.backgroundColor =ZGRandomColor;
    }
    return self;
}

@end

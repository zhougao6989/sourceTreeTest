//
//  ZGShopCell.h
//  瀑布流
//
//  Created by Gao on 16/1/27.
//  Copyright © 2016年 Gao. All rights reserved.
//相当于自定义cell

#import "ZGWorkflowCell.h"

@class ZGShop,ZGWorkflowView;
@interface ZGShopCell : ZGWorkflowCell <NSCopying>

@property (nonatomic,strong) ZGShop *shop;

+(instancetype) shopCellWithWorkflowView:(ZGWorkflowView *)workflowView;


@end

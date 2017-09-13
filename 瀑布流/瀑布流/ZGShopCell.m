//
//  ZGShopCell.m
//  瀑布流
//
//  Created by Gao on 16/1/27.
//  Copyright © 2016年 Gao. All rights reserved.
//

#define ZGColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#import "ZGShopCell.h"
#import "ZGShop.h"
#import "ZGWorkflowView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCache.h>

@interface ZGShopCell()

@property (nonatomic,weak) UIImageView *iconView;

@property (nonatomic,weak) UILabel  *titleLabel;

@end

@implementation ZGShopCell

+(instancetype)shopCellWithWorkflowView:(ZGWorkflowView *)workflowView
{
    static NSString *identifier =@"cell";
    ZGShopCell *cell = (ZGShopCell *)[workflowView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
       // NSLog(@"创建了新cell");
        cell = [[ZGShopCell alloc] init];
        cell.identifier =identifier;
    }
    return cell;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        UIImageView *iconView =[[UIImageView alloc] init];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *label =[[UILabel alloc] init];
        label.font =[UIFont systemFontOfSize:15.0];
        label.textAlignment =NSTextAlignmentCenter;
        label.backgroundColor =ZGColor(0, 0, 0, 0.2);
        [self addSubview:label];
        self.titleLabel =label;
     }
    return self;
}

-(void)setShop:(ZGShop *)shop
{
    _shop = shop;

    [self.iconView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
    
    [self.titleLabel setText:shop.price];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.frame = self.bounds;
    
    CGFloat labelH =20;
    self.titleLabel.frame =CGRectMake(0, self.frame.size.height - labelH, self.frame.size.width, labelH);
    
}

@end

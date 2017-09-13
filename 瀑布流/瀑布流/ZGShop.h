//
//  ZGShop.h
//  瀑布流
//
//  Created by Gao on 16/1/27.
//  Copyright © 2016年 Gao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//继承自UIView子类的控件，父类已经导入了UIKit
@interface ZGShop : NSObject

@property (nonatomic,assign) CGFloat  w;

@property (nonatomic,assign) CGFloat  h;

@property (nonatomic,copy) NSString *img;

@property (nonatomic,copy) NSString *price;

@end

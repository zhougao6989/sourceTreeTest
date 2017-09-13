//
//  ZGWorkflowView.m
//  瀑布流
//
//  Created by Gao on 16/1/26.
//  Copyright © 2016年 Gao. All rights reserved.
//

#import "ZGWorkflowView.h"
#import "UIView+Extension.h"
#import "ZGShopCell.h"
#import <CoreLocation/CoreLocation.h>


@interface ZGWorkflowView ()

/**保存cell的frame */
@property (nonatomic,strong) NSMutableArray *cellFrames;
/**保存当前显示在屏幕上的cell  */
@property (nonatomic,strong) NSMutableDictionary *displayingCells;
/**保存重用的cell */
@property (nonatomic,strong) NSMutableSet *reusableCells;

@end

@implementation ZGWorkflowView
#pragma mark 懒加载 
-(NSMutableArray *) cellFrames
{
    if (!_cellFrames) {
        _cellFrames =[NSMutableArray array];
    }
    return _cellFrames;
}

-(NSMutableDictionary *)displayingCells
{
    if (!_displayingCells) {
        _displayingCells =[NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

-(NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        _reusableCells =[NSMutableSet set];
    }
    return _reusableCells;
}
#pragma mark 特点：当scrollView被拖动时，view会不断调用layoutSubViews来布局子控件
-(void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"%ld ", self.subviews.count);
    int cellFrameCount = (int)self.cellFrames.count;
#warning 当小范围拖动时，cell还在页面上，此时scrollView仍然会不断通过代理方法去获取新的cell，没有必要，将显示页面上的cell暂时用数组存储，当cell仍然在屏幕上时，直接从数组取；当移出屏幕时，才获取新的cell 
    for (int i= 0; i < cellFrameCount ; i++) {
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        ZGShopCell *cell = self.displayingCells[@(i)];
        //如果cell在屏幕上
        if ([self isOnScreen:cellFrame]) {
            if (cell == nil) {
                //数组中没有，从缓存池中取
                cell =(ZGShopCell *)[self.dataSource workflowView:self cellOfIndex:i];
                cell.frame =cellFrame;
                //放在字典中存放
                self.displayingCells[@(i)]= cell;
                [self addSubview:cell];
            }
            
        }else{ //不在屏幕上
            if (cell) {
                //移除屏幕上的cell，删除数组中的cell
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                //放到缓存池
                [self.reusableCells addObject:cell];
            }

        }
           }
    
}

/**判断一个cell是否在屏幕上 */
-(BOOL) isOnScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame)> self.contentOffset.y)&&(CGRectGetMinY(frame)< self.contentOffset.y+self.height);
}

#pragma mark 公共接口
/**
 从无序数组中取得重用的cell
 */
-(ZGShopCell *) dequeueReusableCellWithIdentifier:(NSString *)identifier
{
//    if(!identifier) return nil;
    __block ZGShopCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(ZGShopCell *cell, BOOL * _Nonnull stop) {
        //根据identifier匹配
        if ([identifier isEqualToString:cell.identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    //将即将要重用的cell从缓存池中移除
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma Mark 可选实现的方法
- (NSUInteger) numofColumnsInWorkflowView:(ZGWorkflowView *)workflowView
{
    if([self.dataSource respondsToSelector:@selector(numofColumnsInWorkflowView:)]) {
        return [self.dataSource numofColumnsInWorkflowView:self];
    }else{
        return 3;
    }
}


- (CGFloat)workflowView:(ZGWorkflowView *)workflowView maginByType:(ZGWorkflowViewMarginType) type
{
    if ([self.workflowDelegate respondsToSelector:@selector(workflowView:maginByType:)]) {
        CGFloat margin = [self.workflowDelegate workflowView:self maginByType:type];
        switch (type) {
            case ZGWorkflowViewMarginTypeTop:
                return  margin;
              
            case ZGWorkflowViewMarginTypeLeft:
                return  margin;
                
            case ZGWorkflowViewMarginTypeBottom:
                 return  margin;

            case ZGWorkflowViewMarginTypeRight:
                 return  margin;

            case ZGWorkflowViewMarginTypeRow:
                 return  margin;

            case ZGWorkflowViewMarginTypeCol:
                 return  margin;

            default:
                return 10.0;
        }
    }else{
        return 10.0;
    }
}

-(CGFloat)cellHeightForIndex:(NSUInteger)index
{
    if([self.dataSource respondsToSelector:@selector(cellHeightForIndex:)]) {
        return [self.workflowDelegate cellHeightForIndex:index];
    }else{
        return 10.0;
    }
}
/**根据列数返回每一个cell宽度 */
-(CGFloat) cellWidthWithColumns:(NSUInteger)totalColumns
{
    //水平间距
    CGFloat leftMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeLeft];
    CGFloat rightMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeRight];
    CGFloat colMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeCol];
    CGFloat cellW = (self.width - leftMargin -rightMargin -(totalColumns-1)*colMargin)/totalColumns;
    return cellW;
}
/**
 监听workflowView的触摸
 */
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //返回触摸点在父控件的位置
    CGPoint point = [touch locationInView:self];
//    NSLog(@"%@ , %@" ,[NSValue valueWithCGPoint:point], [NSValue valueWithCGPoint:[touch locationInView:touch.view]]);
    UIView *view =touch.view;
    if ([view isKindOfClass:[ZGShopCell class]]) {
        //触摸到了cell
        //假设触摸到第0个cell
//        __block NSUInteger touchIndex =0 ;
//        [self.cellFrames enumerateObjectsUsingBlock:^(NSValue *cellFrame, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (CGRectContainsPoint([cellFrame CGRectValue], point)) {
//                //在cell内
//                touchIndex =idx;
//                *stop =YES ;
//            }
//        }];
         __block NSUInteger touchIndex =0 ;
        [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, ZGWorkflowCell *cell, BOOL * _Nonnull stop) {
            if (CGRectContainsPoint(cell.frame, point)) {
                //NSNumber转成NSUInteger  
                touchIndex = key.unsignedIntegerValue;
                *stop = YES;
            }
        }];

        //通知代理
        if([self.workflowDelegate respondsToSelector:@selector(workflowView:didSelectCellAtIndex:)]){
            [self.workflowDelegate workflowView:self didSelectCellAtIndex:touchIndex];
        }
    }
}

-(void)reloadData
{
    //让页面上展示的所有旧的cell移除
#warning allValues取出字典中每一个cell事例，返回cell的数组；让数组中每个cell执行removeFromSuperView
    [[self.displayingCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //清除数据
    [self.displayingCells removeAllObjects];
    
    [self.reusableCells removeAllObjects];
    
    [self.cellFrames removeAllObjects];
    
    NSUInteger totalCellCount =[self.dataSource numOfCellsInWorkFlowView:self];
    NSUInteger totalColumns =[self numofColumnsInWorkflowView:self];
    
    CGFloat leftMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeLeft];
    CGFloat colMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeCol];

    //垂直间距
    CGFloat topMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeTop];
    CGFloat bottomMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeBottom];
    CGFloat rowMargin = [self workflowView:self maginByType:ZGWorkflowViewMarginTypeRow];
    
    CGFloat cellW = [self cellWidthWithColumns:totalColumns];
    
    //创建C语言数组保存每一列的最大Y值
    CGFloat maxYOfColumns[totalColumns] ;
    //创建可修改值的一定长度的C数组，必须分开创建数组和初始化的过程
    for (int i =0 ; i < totalColumns; i ++) {
        maxYOfColumns[i] =  0.0 ;
    }
    //默认第一列最短
    CGFloat maxYInMinColunms = maxYOfColumns[0];
    NSUInteger minYCol = 0;
    for (int i =0; i < totalCellCount; i++) {
        //询问代理，cell的高度 
        CGFloat cellH = [self cellHeightForIndex:i];
        
        
        //判断当前哪一列最短，才知道cell在第几列，才能计算X值
        for (int j =0; j < totalColumns; j++) {
            if (maxYOfColumns[j] < maxYInMinColunms) {
                //找出最短那一列的Y
                maxYInMinColunms =maxYOfColumns[j];
                minYCol = j;
            }
        }
        
        //第minYcol列最短，计算X
        CGFloat cellX =leftMargin +(cellW + colMargin)*minYCol;
        CGFloat cellY  =0.0;
        if ( i / totalColumns == 0) {
            //第一行
            cellY = topMargin;
        }else{
            cellY = maxYInMinColunms + rowMargin;
        }
        
        CGRect cellFrame= CGRectMake(cellX, cellY,  cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        //更新最短列的最大Y值
        maxYInMinColunms = CGRectGetMaxY(cellFrame);
        //更新数组中的值 
        maxYOfColumns[minYCol] =maxYInMinColunms;
    }
    //找出所有列的maxY的最大值
    CGFloat maxInMaxY= maxYOfColumns[0];
    for (int j =1; j < totalColumns; j++) {
        if (maxYOfColumns[j] > maxInMaxY) {
            maxInMaxY =maxYOfColumns[j];
        }
    }
    //根据最大Y值设置contentSize
    self.contentSize =CGSizeMake(0 , maxInMaxY + bottomMargin);
}
/**
 当workflowView即将被添加到控制器的view上时，刷新表格
 */
//-(void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [self reloadData];
//}

-(void)didMoveToSuperview
{
    [self reloadData];

}
@end

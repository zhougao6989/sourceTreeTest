//
//  ZGWorkflowView.h
//  瀑布流
//
//  Created by Gao on 16/1/26.
//  Copyright © 2016年 Gao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZGWorkflowView;
@class ZGWorkflowCell;

typedef enum
{
    ZGWorkflowViewMarginTypeTop,
    ZGWorkflowViewMarginTypeLeft,
    ZGWorkflowViewMarginTypeBottom,
    ZGWorkflowViewMarginTypeRight,
    ZGWorkflowViewMarginTypeRow, //每两行cell之间的距离
    ZGWorkflowViewMarginTypeCol //上下两个cell之间的距离
} ZGWorkflowViewMarginType;


#warning mark 数据源方法
/**工作流数据源 */
@protocol ZGWorkflowViewDataSource <NSObject>

@required
/**整个瀑布流一共有多少个cell  */
- (NSUInteger)numOfCellsInWorkFlowView:(ZGWorkflowView *)workflowView ;

/**指定index位置的cell */
- (ZGWorkflowCell *)workflowView:(ZGWorkflowView *)workflowView cellOfIndex:(NSUInteger)index;


@optional
/**整个瀑布流一共有多少列 */
- (NSUInteger)numofColumnsInWorkflowView:(ZGWorkflowView *)workflowView ;


@end

#warning mark 代理方法
/**工作流代理 ，继承scrollView的代理，才有监听滚动的一些特性 */
@protocol ZGWorkflowViewDelegate <UIScrollViewDelegate>

@optional

/**瀑布流cell的行高*/
- (CGFloat)cellHeightForIndex:(NSUInteger) index;

/**瀑布流间距 */
- (CGFloat)workflowView:(ZGWorkflowView *)workflowView maginByType:(ZGWorkflowViewMarginType) type;

/**选中了瀑布流的cell */
- (void)workflowView:(ZGWorkflowView *)workflowView didSelectCellAtIndex:(NSUInteger)index;


@end

@interface ZGWorkflowView : UIScrollView

@property (nonatomic,weak) id<ZGWorkflowViewDataSource> dataSource;

@property (nonatomic,weak) id<ZGWorkflowViewDelegate, UITableViewDelegate> workflowDelegate;

-(void) reloadData;
/**取得可重用的cell  */
-(ZGWorkflowCell *) dequeueReusableCellWithIdentifier:(NSString *)identifier;

/**根据列数返回每一个cell宽度 */
-(CGFloat) cellWidthWithColumns:(NSUInteger)totalColumnsl ;

@end

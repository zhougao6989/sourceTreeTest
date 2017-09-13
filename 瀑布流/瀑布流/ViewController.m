//
//  ViewController.m
//  瀑布流
//
//  Created by Gao on 16/1/26.
//  Copyright © 2016年 Gao. All rights reserved.
//

#import "ViewController.h"
#import "ZGShopCell.h"
#import "ZGWorkflowView.h"
#import "ZGShop.h"
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import <MJRefreshHeader.h>

@interface ViewController ()<ZGWorkflowViewDelegate , ZGWorkflowViewDataSource>

@property (nonatomic,strong) ZGWorkflowView *workflowView;
/**模型的数组*/
@property (nonatomic,strong) NSMutableArray *shops;

@property (nonatomic,strong) MJRefreshHeader *header;

@end

@implementation ViewController

-(NSMutableArray *)shops
{
    if (!_shops) {
        _shops =[NSMutableArray array];
        //自动回去mainBundle取找plist文件，然后将字典数组转模型数组
#warning NSObject的分类，任何数据类型都可以转成Array
        NSMutableArray *shopArray  = [ZGShop mj_objectArrayWithFilename:@"1.plist"];
        NSMutableArray *md = [NSMutableArray arrayWithCapacity:shopArray.count];
        for (ZGShop *shop in shopArray) {
            [md addObject:shop];
        }
        _shops =[md mutableCopy];
    }
    return _shops;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor =[UIColor orangeColor];
    //创建一个工作流
    ZGWorkflowView *workflowView =[[ZGWorkflowView alloc] init];
    workflowView.workflowDelegate =self;
    workflowView.dataSource = self;
    workflowView.frame = self.view.bounds;
     self.workflowView =workflowView;
    //workflowView.backgroundColor =[UIColor blueColor];
    [self.view addSubview:workflowView];
  
#warning MJRefresh框架的特点：任何可以滚动的控件，如UIScrollView，UITableView,UICollectionView都可以添加刷新控件
    //在顶部添加拉刷新控件
    MJRefreshNormalHeader *header =[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header setTitle:@"KB正在帮你加载..." forState:MJRefreshStateRefreshing];
    self.header = header;
    workflowView.mj_header =header;
}

-(void)loadNewData
{
    [self.workflowView.mj_header beginRefreshing];
    NSLog(@"loadNewData");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //加载2.plist文件对应的数据，插入到数组最前面
        NSArray *newShopArray =[ZGShop mj_objectArrayWithFilename:@"2.plist"];
        [self.shops insertObjects:newShopArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShopArray.count)]];
        NSLog(@"dispatch_once");
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.workflowView reloadData];
        
        [[self.workflowView mj_header] endRefreshing];
    });
}
-(NSUInteger)numofColumnsInWorkflowView:(ZGWorkflowView *)workflowView
{
    return 3;
}

-(NSUInteger)numOfCellsInWorkFlowView:(ZGWorkflowView *)workflowView
{
    return self.shops.count;
}

-(ZGShopCell *)workflowView:(ZGWorkflowView *)workflowView cellOfIndex:(NSUInteger)index
{
    ZGShopCell *cell =[ZGShopCell shopCellWithWorkflowView:workflowView];
    
    cell.shop = self.shops[index];
   
    
    return cell;
}

-(CGFloat)cellHeightForIndex:(NSUInteger)index
{
    ZGShop *shop = self.shops[index];
    NSUInteger numOfColumns = [self numofColumnsInWorkflowView:self.workflowView];
    CGFloat cellW = [self.workflowView cellWidthWithColumns:numOfColumns];

    CGFloat cellH = cellW/(shop.w / shop.h);
    return cellH;
}

-(CGFloat) workflowView:(ZGWorkflowView *)workflowView maginByType:(ZGWorkflowViewMarginType)type
{
    switch (type) {
        case ZGWorkflowViewMarginTypeTop:
            return 15;
        case ZGWorkflowViewMarginTypeLeft:
            return 10;
        case ZGWorkflowViewMarginTypeBottom:
            return 10;
        case ZGWorkflowViewMarginTypeRight:
            return 10;
            
        default:
            return 10;
           
    }
}


-(void)workflowView:(ZGWorkflowView *)workflowView didSelectCellAtIndex:(NSUInteger)index
{
    NSLog(@"选中了第%ld个cell" , index);
}


@end

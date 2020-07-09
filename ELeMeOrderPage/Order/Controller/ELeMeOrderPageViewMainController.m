//
//  ELeMeOrderPageViewController.m
//  ELeMe_OrderPage
//
//  Created by liyifang on 2017/7/10.
//  Copyright © 2017年 liyifang. All rights reserved.
//

#import "ELeMeOrderPageViewMainController.h"
#import "Masonry.h"

#define TableHeaderViewH  200
#define kNavBarHeight 88

static CGFloat const kTakeoutDetailStickViewHeight = 45;

//子视图
#import "ELeMeOrderPageLevelListView.h"
//子控制器
#import "ELeMeOrderPageLeftViewController.h"
#import "ELeMeOrderPageRightViewController.h"

#import "OrderFoodModel.h"
@interface ELeMeOrderPageViewMainController ()<UITableViewDelegate,UITableViewDataSource,ELeMeOrderPageLevelListViewDelegate>

@property(nonatomic, strong)UITableView *mainTableView;//主tableView
@property(nonatomic, strong)UIScrollView *subScrollView;//添加到cell的滚动视图 实现 “点菜” “商家滑动切换”
@property(nonatomic, strong)ELeMeOrderPageLeftViewController *subLeftVC;//点菜控制器
@property(nonatomic, strong)ELeMeOrderPageRightViewController *subRightVC;//商家控制器
@property(nonatomic, strong)ELeMeOrderPageLevelListView *levelListView;//section头视图
@property(nonatomic, strong) OrderFoodModel *foodModel;
@property (nonatomic, assign) CGFloat mainTableViewOldOffSet;

@end

@implementation ELeMeOrderPageViewMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)initial {
    // 初始化 UI
    
    // 主列表
    [self initMainTableView];
    [self initSubScrollView];

    // 解析数据

    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"OrderShamData" ofType:@"plist"];
    NSArray *dataArr = [NSArray arrayWithContentsOfFile:dataPath];
    self.foodModel = [[OrderFoodModel alloc]init];
    [_foodModel getMenuTypesModelFromDataArr:dataArr];
    self.subLeftVC.orderFoodModel = _foodModel;
    [_mainTableView reloadData];
}

- (void)initMainTableView {
    _mainTableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //设置代理
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    //设置头视图
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, TableHeaderViewH)];
    headerView.backgroundColor = [UIColor brownColor];
    _mainTableView.tableHeaderView = headerView;

    [self.view addSubview:self.mainTableView];
    [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.leading.trailing.bottom.mas_equalTo(0);
    }];

}

- (void)initSubScrollView {
    
    CGRect frame = self.view.bounds;
    frame.origin.y = 0;
    frame.size.height -= kNavBarHeight+kTakeoutDetailStickViewHeight;
    _subScrollView = [[UIScrollView alloc]initWithFrame:frame];
    _subScrollView.contentSize = CGSizeMake(ScreenWidth*2, frame.size.height);
    _subScrollView.pagingEnabled = YES;
    _subScrollView.delegate = self;
    _subScrollView.bounces = NO;
    
    [self initSubLeftVC];
    [self initSubRightVC];


}

- (void)initSubLeftVC {
    _subLeftVC = [[ELeMeOrderPageLeftViewController alloc]init];
    _subLeftVC.view.frame = self.subScrollView.bounds;
    [self addChildViewController:_subLeftVC];
    [_subScrollView addSubview:self.subLeftVC.view];

}

- (void)initSubRightVC {
    CGRect frame = self.subScrollView.bounds;
    frame.origin.x = ScreenWidth;
    _subRightVC = [[ELeMeOrderPageRightViewController alloc]init];
      _subRightVC.view.frame =frame;
    [self addChildViewController:_subRightVC];
    [_subScrollView addSubview:self.subRightVC.view];

}

#pragma mark - delegate实现

/**
 ELeMeOrderPageLevelListViewDelegate
 */
- (void)selectedButton:(BOOL)isLeftButton {
    CGPoint offSet = _subScrollView.contentOffset;
    offSet.x = isLeftButton ? 0 : ScreenWidth;
    [_subScrollView setContentOffset:offSet animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionNum = 1;
    return sectionNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowNum = 1;
    
    return rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.subScrollView removeFromSuperview];
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    [cell.contentView addSubview:self.subScrollView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = self.subScrollView.bounds.size.height;
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTakeoutDetailStickViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_levelListView) {
        _levelListView = [[ELeMeOrderPageLevelListView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kTakeoutDetailStickViewHeight)];
        _levelListView.delegate = self;
    }
    return _levelListView;
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:self.mainTableView]) {
//
//        NSLog(@"%lf, %lf", scrollView.contentOffset.y, scrollView.contentSize.height-scrollView.bounds.size.height);
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height-scrollView.bounds.size.height-0.5)) {//mainTableView 滚动不能超过最大值
            self.offsetType = OffsetTypeMax;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height-scrollView.bounds.size.height);//(scrollView.contentSize.height-scrollView.bounds.size.height):mainTableView 可以滚动的最大偏移距离 超过等于最大偏移距离 不可以再向上滑动
             _mainTableViewOldOffSet = scrollView.contentSize.height-scrollView.bounds.size.height;
        } else if (scrollView.contentOffset.y <= 0) {
            self.offsetType = OffsetTypeMin;
        } else {
            self.offsetType = OffsetTypeCenter;
        }
        
       
       
        if ((self.levelListView.selectedIndex == 0 && self.subLeftVC.offsetType != OffsetTypeMin)&&(self.subLeftVC.rightTVScrollDown||(scrollView.contentOffset.y-_mainTableViewOldOffSet<0))) {//self.subLeftVC.offsetType != OffsetTypeMin时_mainTableView不能向下滑动（注释：当点菜页面显示并且商品列表tableView未达到最大偏移量之前，mainTableView不能向下滑动 ）
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, _mainTableViewOldOffSet);
        }
        
      
        if (self.levelListView.selectedIndex == 1 &&self.subRightVC.offsetType != OffsetTypeMin) {//当商家页面显示时，商家信息tableview偏移量不是最小状态 说明mainTableView 已经滚动到了最大值 在商家信息tableview偏移量未达到最小偏移量之前  mainTableView需要保持原来的偏移量不变
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, _mainTableViewOldOffSet);
        }
        
        _mainTableViewOldOffSet = scrollView.contentOffset.y;
        
    }
    
    if ([scrollView isEqual:self.subScrollView]) {
        [self.levelListView changeLineViewOffsetX:self.subScrollView.contentOffset.x];
    }
    
    
}


@end

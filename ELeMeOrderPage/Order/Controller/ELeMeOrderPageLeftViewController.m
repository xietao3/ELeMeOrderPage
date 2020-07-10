//
//  ELeMeOrderPageLeftViewController.m
//  ELeMe_OrderPage
//
//  Created by liyifang on 2017/7/12.
//  Copyright © 2017年 liyifang. All rights reserved.
//

#import "ELeMeOrderPageLeftViewController.h"
#import "ELeMeOrderPageViewMainController.h"
#import "ELeMeOrderPageLeftVCCell.h"
#import "Header.h"
@interface ELeMeOrderPageLeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) LWGesturePenetrationTableView *productTableView;
@property(nonatomic, strong) UITableView *categoryTableView;

@property (nonatomic, assign) BOOL didSelectCategoryScrolling;
@property (nonatomic, assign) CGFloat oldProductTableViewOffsetY;

@end

@implementation ELeMeOrderPageLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)initial {
    [self initProductTableView];
    [self initCategoryTableView];
    __weak __typeof(self) weakSelf = self;
    [self.view addSubview:self.categoryTableView];
    [self.view addSubview:self.productTableView];
    [self.categoryTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(90);
    }];
    [self.productTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(weakSelf.categoryTableView.mas_right).with.offset(0);
        make.right.mas_equalTo(0);
    }];
}

- (void)initCategoryTableView {
    _categoryTableView = [[UITableView alloc]init];
    _categoryTableView.delegate = self;
    _categoryTableView.dataSource = self;
    
    [_categoryTableView registerClass:[ELeMeOrderPageLeftVCLeftCell class] forCellReuseIdentifier:@"cell1"];

}

- (void)initProductTableView {
    _productTableView = [[LWGesturePenetrationTableView alloc]init];
    _productTableView.delegate = self;
    _productTableView.dataSource = self;
    _productTableView.showsVerticalScrollIndicator = NO;
    [_productTableView registerClass:[ELeMeOrderPageLeftVCRightCell class] forCellReuseIdentifier:@"cell2"];

}

#pragma mark - PublicMehtod
- (void)setOrderFoodModel:(OrderFoodModel *)orderFoodModel {
    _orderFoodModel = orderFoodModel;
    [self.productTableView reloadData];
    [self.categoryTableView reloadData];
    if (_orderFoodModel.menuTypesModelArr.count>0) {
        NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_categoryTableView selectRowAtIndexPath:targetIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}


#pragma mark - PricateMethod
- (void)scrollProductTableViewWhenSelectRowInCategoryTableViewAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.row;
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:section];
    [_productTableView scrollToRowAtIndexPath:targetIndexPath atScrollPosition: UITableViewScrollPositionTop animated:YES];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger num;
    if (tableView==self.categoryTableView) {
         num = 1;
    }
    else{
        num = _orderFoodModel.menuTypesModelArr.count;
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num;
    if (tableView==self.categoryTableView) {
          num = _orderFoodModel.menuTypesModelArr.count;
    }else{
        OrderFoodMenuTypeModel *menuTypeModel = _orderFoodModel.menuTypesModelArr[section];
        num = menuTypeModel.menusModelArr.count;
    }
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = tableView == self.categoryTableView ? 48 : 79;
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = tableView == self.productTableView ? 20 : 0.01;
    return headerHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.categoryTableView) {
       OrderFoodMenuTypeModel *menuType = self.orderFoodModel.menuTypesModelArr[indexPath.row];
       ELeMeOrderPageLeftVCLeftCell *leftCell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        leftCell.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
        leftCell.text = menuType.goods_type;
        UIView *selectedBackgroundView = [[UIView alloc]init];
        UIView *lineVView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 48)];
        lineVView.backgroundColor = UIColor_0398ff;
        selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        [selectedBackgroundView addSubview:lineVView];
        leftCell.selectedBackgroundView = selectedBackgroundView;
        return leftCell;
    }else{
        
        ELeMeOrderPageLeftVCRightCell *rightCell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        rightCell.isFirst = YES;
        rightCell.selectionStyle =  UITableViewCellSelectionStyleNone;
        rightCell.backgroundColor=[UIColor whiteColor];
        
        //
        OrderFoodMenuTypeModel *menuType = self.orderFoodModel.menuTypesModelArr[indexPath.section];
        __block OrderFoodMenuModel *menuModel = menuType.menusModelArr[indexPath.row];
        menuModel.indexPath = indexPath;
        //
        rightCell.goodsImgUrlStr = menuModel.pic;//商品图片视图
        rightCell.titleStr = menuModel.name;//商品标题
        rightCell.saleNumberStr = [NSString stringWithFormat:@"已售%@份",menuModel.sales]; //销量
        rightCell.priceStr =  menuModel.price;//价格
        rightCell.shopNumberStr = [NSString stringWithFormat:@"%ld",(long)menuModel.shopNum];//购买量
        
        [rightCell clickButtonBloak:^(NSInteger shopNumChange) {
            
            
        }];
        return rightCell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    if (tableView==self.productTableView) {
        OrderFoodMenuTypeModel *menuType = self.orderFoodModel.menuTypesModelArr[section];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-10, 20)];
        [view addSubview:lable];
        lable.font = [UIFont systemFontOfSize:11];
        lable.textColor = UIColor_333333;
        lable.text = menuType.goods_type;
    }
    
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return view;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView==self.categoryTableView) {
        [self scrollProductTableViewWhenSelectRowInCategoryTableViewAtIndexPath:indexPath];
        _didSelectCategoryScrolling = YES;
    }
}

// productTableView 实现联动 : productTableViews 顶部 section头消失出现 实现 categoryTableView 选择联动
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if (!_didSelectCategoryScrolling&&tableView==self.productTableView&&_rightTVScrollUp) {
        NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:section+1 inSection:0];
        if ((section+1)<_orderFoodModel.menuTypesModelArr.count) {
            [_categoryTableView selectRowAtIndexPath:targetIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    if (!_didSelectCategoryScrolling&&tableView==self.productTableView&&_rightTVScrollDown) {
        NSIndexPath *targetIndexPath = [NSIndexPath indexPathForRow:section inSection:0];
        [_categoryTableView selectRowAtIndexPath:targetIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }

}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    ELeMeOrderPageViewMainController *vc = (ELeMeOrderPageViewMainController *)[self parentViewController];//父控制器
    
    if (scrollView == self.productTableView && !_didSelectCategoryScrolling) {
        
        // 切换 tableView ContentOffset 位置状态
        if (scrollView.contentOffset.y <= 0) {
            // productTableView 不能小于最小值（不能下滑的条件）
            self.scrollOffset = ScrollOffsetZero;
            scrollView.contentOffset = CGPointZero;
        } else {
            self.scrollOffset = ScrollOffsetOther;
        }
        
        
        // 判断滑动方向
        if (scrollView.contentOffset.y > _oldProductTableViewOffsetY) {
            _rightTVScrollUp = YES;
            _rightTVScrollDown =  !_rightTVScrollUp;
        } else if (scrollView.contentOffset.y < _oldProductTableViewOffsetY) {
            _rightTVScrollUp = NO;
            _rightTVScrollDown =  !_rightTVScrollUp;
        }
        
        
        // vc.scrollOffset != ScrollOffsetGreaterThanHeader 时 productTableView 不能向上滑动（不能上滑的条件）
        if (vc.scrollOffset != ScrollOffsetGreaterThanHeader && _rightTVScrollUp) {
            scrollView.contentOffset = CGPointMake(0, _oldProductTableViewOffsetY);
        }
                
        _oldProductTableViewOffsetY = floorf(scrollView.contentOffset.y);
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView==self.productTableView) {
        _didSelectCategoryScrolling = NO;
        _oldProductTableViewOffsetY = floorf(scrollView.contentOffset.y);
    }
}



@end

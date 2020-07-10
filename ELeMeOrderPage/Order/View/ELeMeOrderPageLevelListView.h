//
//  LWLevelListView.h
//  ELeMe_OrderPage
//
//  Created by liyifang on 2017/7/12.
//  Copyright © 2017年 liyifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELeMeOrderPageLevelListView : UIView
@property(nonatomic, strong)UIButton *leftButton;
@property(nonatomic, strong)UIButton *rightButton;
@property(nonatomic, assign)NSInteger selectedIndex;
@property (nonatomic, copy) void(^segmentIndexDidChangeBlock)(NSInteger index);

- (void)changeLineViewOffsetX:(CGFloat)offsetX;


@end

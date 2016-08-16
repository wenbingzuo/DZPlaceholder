//
//  ViewController.m
//  DZPlaceholderDemo
//
//  Created by Wenbing Zuo on 8/12/16.
//  Copyright © 2016 Wenbing Zuo. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import <Masonry.h>
#import "UIScrollView+DZPlaceholder.h"

@interface ViewController () <DZScrollViewPlaceholderDataSource>

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation ViewController

- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DZPlaceholder";
    
    self.tableView.backgroundColor = [UIColor orangeColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.dz_placeholderDataSource = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [self.tableView.mj_header beginRefreshing];
}

static BOOL flag = YES;

- (void)loadData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            [temp addObject:[NSString stringWithFormat:@"随机数据 --- %@", @(i)]];
        }
        if (flag) {
            self.data = temp;
        } else {
            [self.data removeAllObjects];
        }
        [self.tableView reloadData];
        
        flag = !flag;
        [self.tableView.mj_header endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

- (void)tableview:(UITableView *)tableView configPlaceholderInContainerView:(UIView *)containerView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(0.0, -100.0));
    }];
    [button setTitle:@"点击一下自动刷新" forState:UIControlStateNormal];
    [button addTarget:self.tableView.mj_header action:@selector(beginRefreshing) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)canScrollWhenShowingPlaceholderInTableView:(UITableView *)tableView {
    return NO;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @[[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.data removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView.mj_header beginRefreshing];
}

- (void)scrollView:(UIScrollView *)scrollView configPlaceholderInContainerView:(UIView *)containerView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(containerView);
    }];
    [button setTitle:@"你点一下嘛" forState:UIControlStateNormal];
    [button addTarget:self.tableView.mj_header action:@selector(beginRefreshing) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)canScrollWhenShowingPlaceholderInScrollView:(UIScrollView *)scrollView {
    return YES;
}

@end

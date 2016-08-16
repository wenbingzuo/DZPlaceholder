//
//  DZCollectionViewController.m
//  DZPlaceholderDemo
//
//  Created by Wenbing Zuo on 8/16/16.
//  Copyright © 2016 Wenbing Zuo. All rights reserved.
//

#import "DZCollectionViewController.h"
#import "UIScrollView+DZPlaceholder.h"
#import "Masonry.h"

@interface DZCollectionViewController () <DZScrollViewPlaceholderDataSource>

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation DZCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    CGFloat width = (CGRectGetWidth(self.view.frame) - 5.0 * 4)/5;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 5.0;
    flowLayout.minimumLineSpacing = 5.0;
    flowLayout.itemSize = CGSizeMake(width, width);
    
    self.collectionView.dz_placeholderDataSource = self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate


#pragma mark - DZScrollViewPlaceholderDataSource

- (void)scrollView:(UIScrollView *)scrollView configPlaceholderInContainerView:(UIView *)containerView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(containerView).multipliedBy(1/3.0);
        make.centerX.equalTo(containerView);
    }];
    [button setTitle:@"lala" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (IBAction)deleteAction:(id)sender {
    if (self.data.count == 0) return;
    [self.data removeLastObject];
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.data.count inSection:0]]];
}

- (IBAction)addAction:(id)sender {
    [self.data addObject:[NSString stringWithFormat:@"第%@个", @(self.data.count)]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.data.count - 1 inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
}

@end

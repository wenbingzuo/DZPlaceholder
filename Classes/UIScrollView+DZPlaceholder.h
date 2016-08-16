//
//  UITableView+DZPlaceholder.h
//  DZPlaceholderDemo
//
//  Created by Wenbing Zuo on 8/12/16.
//  Copyright © 2016 Wenbing Zuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DZScrollViewPlaceholderDataSource <NSObject>

@optional

- (BOOL)shouldShowPlaceholderInScrollView:(UIScrollView *)scrollView;

- (void)scrollView:(UIScrollView *)scrollView configPlaceholderInContainerView:(UIView *)containerView;

- (BOOL)canScrollWhenShowingPlaceholderInScrollView:(UIScrollView *)scrollView;

@end

@interface UIScrollView (DZPlaceholder)

@property (nonatomic, weak) id <DZScrollViewPlaceholderDataSource> dz_placeholderDataSource;

- (void)dz_reloadPlaceholder;

@end
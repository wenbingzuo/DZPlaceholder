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

/**
 Manually control the state of placeholder view.
 */
- (BOOL)shouldShowPlaceholderInScrollView:(UIScrollView *)scrollView;

/**
 Add placeholder view to the `containerView`.
 */
- (void)scrollView:(UIScrollView *)scrollView configPlaceholderInContainerView:(UIView *)containerView;

/**
 It just take affect when the placeholder view is showing.
 */
- (BOOL)canScrollWhenShowingPlaceholderInScrollView:(UIScrollView *)scrollView;

@end

@interface UIScrollView (DZPlaceholder)

/**
 The placeholder data source.
 */
@property (nonatomic, weak) id <DZScrollViewPlaceholderDataSource> dz_placeholderDataSource;

/**
 Reload the placeholder view. Will not invoke `-reloadData`.
 */
- (void)dz_reloadPlaceholder;

@end
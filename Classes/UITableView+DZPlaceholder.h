//
//  UITableView+DZPlaceholder.h
//  DZPlaceholderDemo
//
//  Created by Wenbing Zuo on 8/12/16.
//  Copyright © 2016 Wenbing Zuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DZTableViewPlaceholderDataSource <UITableViewDataSource>

@optional

- (void)tableview:(UITableView *)tableView configPlaceholderInContainerView:(UIView *)containerView;

- (BOOL)canScrollWhenShowingPlaceholderInTableView:(UITableView *)tableView;

@end

@interface UITableView (DZPlaceholder)

@end

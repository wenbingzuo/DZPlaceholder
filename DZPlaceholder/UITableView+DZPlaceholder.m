//
//  UITableView+DZPlaceholder.m
//  DZPlaceholderDemo
//
//  Created by Wenbing Zuo on 8/12/16.
//  Copyright © 2016 Wenbing Zuo. All rights reserved.
//

#import "UITableView+DZPlaceholder.h"
#import <objc/runtime.h>

@interface UITableView ()
@property (nonatomic, assign) BOOL __dz_scrollEnabled;
@property (nonatomic, strong) UIView *__dz_innerPlaceholderContainerView;
@end

@implementation UITableView (DZPlaceholder)

- (UIView *)__dz_innerPlaceholderContainerView {
    UIView *containerView = objc_getAssociatedObject(self, _cmd);
    if (!containerView) {
        containerView = [UIView new];
        containerView.backgroundColor = [UIColor clearColor];
        objc_setAssociatedObject(self, _cmd, containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return containerView;
}

- (void)set__dz_scrollEnabled:(BOOL)__dz_scrollEnabled {
    objc_setAssociatedObject(self, @selector(__dz_scrollEnabled), @(__dz_scrollEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)__dz_scrollEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)__dz_addPlaceholderConstraints {
    UIView *innerPlaceholder = self.__dz_innerPlaceholderContainerView;
    
    innerPlaceholder.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsBinding = NSDictionaryOfVariableBindings(innerPlaceholder, self);
    UIEdgeInsets padding = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    NSDictionary *metrics = @{@"topPadding":@(padding.top),
                              @"leftPadding":@(padding.left),
                              @"bottomPadding":@(padding.bottom),
                              @"rightPadding":@(padding.right)};
    NSString *vFormat = nil;
    NSString *hFormat = nil;
    if ([self isKindOfClass:[UIScrollView class]]) {
        vFormat = @"V:|-topPadding-[innerPlaceholder(self)]-bottomPadding-|";
        hFormat = @"H:|-leftPadding-[innerPlaceholder(self)]-rightPadding-|";
    } else {
        vFormat = @"V:|-topPadding-[innerPlaceholder]-bottomPadding-|";
        hFormat = @"H:|-leftPadding-[innerPlaceholder]-rightPadding-|";
    }
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vFormat options:kNilOptions metrics:metrics views:viewsBinding]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hFormat options:kNilOptions metrics:metrics views:viewsBinding]];
}

- (void)__dz_showPlaceholder {
    [self.__dz_innerPlaceholderContainerView removeFromSuperview];
    [self addSubview:self.__dz_innerPlaceholderContainerView];
    [self __dz_addPlaceholderConstraints];
}

- (void)__dz_removePlaceholder {
    [self.__dz_innerPlaceholderContainerView removeFromSuperview];
}

- (void)__dz_managePlaceholder {
    id <UITableViewDataSource> dataSource = self.dataSource;
    
    BOOL viewForPlaceholderFlag = [dataSource respondsToSelector:@selector(tableview:configPlaceholderInContainerView:)];
    if (!viewForPlaceholderFlag) return;
    
    BOOL hasNoData = YES;
    NSUInteger numberOfSections = 1;
    if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        numberOfSections = [dataSource numberOfSectionsInTableView:self];
    }
    for (int i = 0; i < numberOfSections; i++) {
        NSUInteger numberOfRows = [dataSource tableView:self numberOfRowsInSection:i];
        if (numberOfRows != 0) {
            hasNoData = NO;
            break;
        }
    }
    
    BOOL canScrollFlag = [dataSource respondsToSelector:@selector(canScrollWhenShowingPlaceholderInTableView:)];
    if (canScrollFlag) {
        if (hasNoData) {
            if (!self.__dz_innerPlaceholderContainerView.superview) {
                self.__dz_scrollEnabled = self.scrollEnabled;
            }
            BOOL flag = [dataSource performSelector:@selector(canScrollWhenShowingPlaceholderInTableView:) withObject:self];
            self.scrollEnabled = flag;
        } else {
            self.scrollEnabled = self.__dz_scrollEnabled;
        }
    }
    
    if (hasNoData) {
        [dataSource performSelector:@selector(tableview:configPlaceholderInContainerView:) withObject:self withObject:self.__dz_innerPlaceholderContainerView];
        [self __dz_showPlaceholder];
        [self __dz_addPlaceholderConstraints];
    } else {
        [self __dz_removePlaceholder];
    }
}

@end

@interface UITableView (DZPlaceholderForward)
@end

@implementation UITableView (DZPlaceholderForward)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL selectors[] = {
            @selector(reloadData),
            @selector(insertSections:withRowAnimation:),
            @selector(deleteSections:withRowAnimation:),
            @selector(reloadSections:withRowAnimation:),
            @selector(moveSection:toSection:),
            @selector(insertRowsAtIndexPaths:withRowAnimation:),
            @selector(deleteRowsAtIndexPaths:withRowAnimation:),
            @selector(reloadRowsAtIndexPaths:withRowAnimation:),
            @selector(moveRowAtIndexPath:toIndexPath:)
        };
        
        for (int i = 0; i < sizeof(selectors)/sizeof(SEL); i++) {
            SEL originalSelector = selectors[i];
            SEL swizzledSelector = NSSelectorFromString([@"dz_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            
            BOOL success = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            if (success) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (void)dz_reloadData {
    [self __dz_managePlaceholder];
    [self dz_reloadData];
}

- (void)dz_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self __dz_managePlaceholder];
    [self dz_insertSections:sections withRowAnimation:animation];
}

- (void)dz_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self __dz_managePlaceholder];
    [self dz_deleteSections:sections withRowAnimation:animation];
}

- (void)dz_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self __dz_managePlaceholder];
    [self dz_reloadSections:sections withRowAnimation:animation];
}

- (void)dz_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self __dz_managePlaceholder];
    [self dz_moveSection:section toSection:newSection];
}

- (void)dz_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self __dz_managePlaceholder];
    [self dz_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)dz_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self __dz_managePlaceholder];
    [self dz_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)dz_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self __dz_managePlaceholder];
    [self dz_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)dz_moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self __dz_managePlaceholder];
    [self dz_moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

@end
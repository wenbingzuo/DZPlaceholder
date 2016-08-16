//
//  UITableView+DZPlaceholder.m
//  DZPlaceholderDemo
//
//  Created by Wenbing Zuo on 8/12/16.
//  Copyright © 2016 Wenbing Zuo. All rights reserved.
//

#import "UIScrollView+DZPlaceholder.h"
#import <objc/runtime.h>

@interface UIScrollView ()
@property (nonatomic, assign) BOOL __dz_scrollEnabled;
@property (nonatomic, strong) UIView *__dz_innerPlaceholderContainerView;
@end

@implementation UIScrollView (DZPlaceholder)

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

- (void)setDz_placeholderDataSource:(id<DZScrollViewPlaceholderDataSource>)dz_placeholderDataSource {
    objc_setAssociatedObject(self, @selector(dz_placeholderDataSource), dz_placeholderDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<DZScrollViewPlaceholderDataSource>)dz_placeholderDataSource {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)__dz_shouldManagePlaceholder {
    return self.dz_placeholderDataSource && [self.dz_placeholderDataSource respondsToSelector:@selector(scrollView:configPlaceholderInContainerView:)];
}

- (BOOL)__dz_shouldShowPlaceholder {
    if ([self.dz_placeholderDataSource respondsToSelector:@selector(shouldShowPlaceholderInScrollView:)]) {
        return [self.dz_placeholderDataSource shouldShowPlaceholderInScrollView:self];
    } else if ([self isMemberOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        BOOL hasNoData = YES;
        NSUInteger numberOfSections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            numberOfSections = [dataSource numberOfSectionsInTableView:tableView];
        }
        for (int i = 0; i < numberOfSections; i++) {
            NSUInteger numberOfRows = [dataSource tableView:tableView numberOfRowsInSection:i];
            if (numberOfRows != 0) {
                hasNoData = NO;
                break;
            }
        }
        return hasNoData;
    } else if ([self isMemberOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        BOOL hasNoData = YES;
        NSUInteger numberOfSections = 1;
        if ([dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            numberOfSections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        for (int i = 0; i < numberOfSections; i++) {
            NSUInteger numberOfItems = [dataSource collectionView:collectionView numberOfItemsInSection:i];
            if (numberOfItems != 0) {
                hasNoData = NO;
                break;
            }
        }
        return hasNoData;
    } else {
        return NO;
    }
}

- (void)__dz_managePlaceholder {
    if (![self __dz_shouldManagePlaceholder]) return;
    
    BOOL showPlaceholderFlag = [self __dz_shouldShowPlaceholder];
    BOOL canScrollFlag = [self.dz_placeholderDataSource respondsToSelector:@selector(canScrollWhenShowingPlaceholderInScrollView:)];
    if (canScrollFlag) {
        if (!self.__dz_innerPlaceholderContainerView.superview) {
            self.__dz_scrollEnabled = self.scrollEnabled;
        }
        if (showPlaceholderFlag) {
            BOOL flag = [self.dz_placeholderDataSource canScrollWhenShowingPlaceholderInScrollView:self];
            self.scrollEnabled = flag;
        } else {
            self.scrollEnabled = self.__dz_scrollEnabled;
        }
    }
    
    if (showPlaceholderFlag) {
        [self.dz_placeholderDataSource scrollView:self configPlaceholderInContainerView:self.__dz_innerPlaceholderContainerView];
        [self __dz_showPlaceholder];
        [self __dz_addPlaceholderConstraints];
    } else {
        [self __dz_removePlaceholder];
    }
}

- (void)dz_reloadPlaceholder {
    [self __dz_managePlaceholder];
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
            @selector(insertRowsAtIndexPaths:withRowAnimation:),
            @selector(deleteRowsAtIndexPaths:withRowAnimation:),
            @selector(reloadRowsAtIndexPaths:withRowAnimation:)
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

@end

@interface UICollectionView (DZPlaceholderForward)
@end

@implementation UICollectionView (DZPlaceholderForward)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL selectors[] = {
            @selector(reloadData),
            @selector(insertSections:),
            @selector(deleteSections:),
            @selector(moveSection:toSection:),
            @selector(insertItemsAtIndexPaths:),
            @selector(deleteItemsAtIndexPaths:),
            @selector(reloadItemsAtIndexPaths:),
            @selector(moveItemAtIndexPath:toIndexPath:)
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

- (void)dz_insertSections:(NSIndexSet *)sections {
    [self __dz_managePlaceholder];
    [self dz_insertSections:sections];
}

- (void)dz_deleteSections:(NSIndexSet *)sections {
    [self __dz_managePlaceholder];
    [self dz_deleteSections:sections];
}

- (void)dz_reloadSections:(NSIndexSet *)sections {
    [self __dz_managePlaceholder];
    [self dz_reloadSections:sections];
}

- (void)dz_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self __dz_managePlaceholder];
    [self dz_insertItemsAtIndexPaths:indexPaths];
}

- (void)dz_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self __dz_managePlaceholder];
    [self dz_deleteItemsAtIndexPaths:indexPaths];
}

- (void)dz_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    [self __dz_managePlaceholder];
    [self dz_reloadItemsAtIndexPaths:indexPaths];
}

@end

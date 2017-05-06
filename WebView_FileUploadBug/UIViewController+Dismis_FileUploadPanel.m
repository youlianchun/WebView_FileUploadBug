//
//  UIViewController+Dismis.m
//  WebView_FileUploadBug
//
//  Created by YLCHUN on 2017/4/27.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "UIViewController+Dismis_FileUploadPanel.h"
#import <objc/runtime.h>

@interface UIViewController ()
@property (nonatomic) BOOL FileUploadPanelFlag;
@end
@implementation UIViewController (Dismis_FileUploadPanel)

-(BOOL)FileUploadPanelFlag {
    return [objc_getAssociatedObject(self, @selector(FileUploadPanelFlag)) boolValue];
}
-(void)setFileUploadPanelFlag:(BOOL)FileUploadPanelFlag {
    objc_setAssociatedObject(self, @selector(FileUploadPanelFlag), @(FileUploadPanelFlag), OBJC_ASSOCIATION_RETAIN);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(dismissViewControllerAnimated:completion:);
        SEL swizzledSelector = @selector(_dismissViewControllerAnimated:completion:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        originalSelector = @selector(presentViewController:animated:completion:);
        swizzledSelector = @selector(_presentViewController:animated:completion:);
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


-(void)_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    static BOOL dismisFromFileUploadPanel = NO;
    if (!dismisFromFileUploadPanel) {
        [self _dismissViewControllerAnimated:flag completion:^{
            if (completion) {
                if (self.FileUploadPanelFlag) {
                    dismisFromFileUploadPanel = YES;
                    completion();
                    dismisFromFileUploadPanel = NO;
                }else{
                    completion();
                }
            }
        }];
    }
}

-(void)_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if ([viewControllerToPresent isKindOfClass:[UIDocumentMenuViewController class]]) {
        UIDocumentMenuViewController *dvc = (UIDocumentMenuViewController*)viewControllerToPresent;
        if ([dvc.delegate isKindOfClass:NSClassFromString(@"WKFileUploadPanel")] || [dvc.delegate isKindOfClass:NSClassFromString(@"UIWebFileUploadPanel")]) {
            self.FileUploadPanelFlag = YES;
            dvc.FileUploadPanelFlag = YES;
        }
    }
    [self _presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end

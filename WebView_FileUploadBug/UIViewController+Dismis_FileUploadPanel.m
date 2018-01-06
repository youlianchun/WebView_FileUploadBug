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

-(BOOL)FileUploadPanelFlag
{
    return [objc_getAssociatedObject(self, @selector(FileUploadPanelFlag)) boolValue];
}

-(void)setFileUploadPanelFlag:(BOOL)FileUploadPanelFlag
{
    objc_setAssociatedObject(self, @selector(FileUploadPanelFlag), @(FileUploadPanelFlag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void dfup_swizzledMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dfup_swizzledMethod(self, @selector(dismissViewControllerAnimated:completion:), @selector(dfup_dismissViewControllerAnimated:completion:));
        dfup_swizzledMethod(self, @selector(presentViewController:animated:completion:), @selector(dfup_presentViewController:animated:completion:));
    });
}


-(void)dfup_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    static BOOL dismisFromFileUploadPanel = NO;
    if (!dismisFromFileUploadPanel)
    {
        [self dfup_dismissViewControllerAnimated:flag completion:^{
            if (completion)
            {
                if (self.FileUploadPanelFlag)
                {
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

-(void)dfup_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    //viewControllerToPresent -> UIDocumentMenuViewController UIDocumentPickerViewController
    if ([viewControllerToPresent respondsToSelector:@selector(delegate)])
    {
        id delegate = [viewControllerToPresent valueForKey:@"delegate"];
        if ([delegate isKindOfClass:objc_getRequiredClass("WKFileUploadPanel")] || [delegate isKindOfClass:objc_getRequiredClass("UIWebFileUploadPanel")])
        {
            self.FileUploadPanelFlag = YES;
            viewControllerToPresent.FileUploadPanelFlag = YES;
        }
    }
    [self dfup_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end


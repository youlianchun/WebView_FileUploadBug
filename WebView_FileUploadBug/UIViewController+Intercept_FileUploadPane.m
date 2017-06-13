//
//  UIViewController+Intercept_FileUploadPane.m
//  WebView_FileUploadBug
//
//  Created by YLCHUN on 2017/6/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "UIViewController+Intercept_FileUploadPane.h"
#import <objc/runtime.h>

@implementation UIViewController (Intercept_FileUploadPane)
    
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzledSelectorWithClassString:@"WKFileUploadPanel"];
        [self swizzledSelectorWithClassString:@"UIWebFileUploadPanel"];
    });
}

+(void)swizzledSelectorWithClassString:(NSString*)classString {
    Class class = NSClassFromString(classString);
    if (class) {
        SEL originalSelector = NSSelectorFromString(@"imagePickerController:didFinishPickingMediaWithInfo:");
        SEL swizzledSelector = @selector(_imagePickerController:didFinishPickingMediaWithInfo:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        originalSelector = NSSelectorFromString(@"imagePickerController:didFinishPickingMultipleMediaWithInfo:");
        swizzledSelector = @selector(_imagePickerController:didFinishPickingMultipleMediaWithInfo:);
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

- (void)_imagePickerController:(UIImagePickerController *)imagePicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //拦截代码。。。
    [self _imagePickerController:imagePicker didFinishPickingMediaWithInfo:info];
}

- (void)_imagePickerController:(UIImagePickerController *)imagePicker didFinishPickingMultipleMediaWithInfo:(NSArray *)infos  {
    //拦截代码。。。
    [self _imagePickerController:imagePicker didFinishPickingMultipleMediaWithInfo:infos];
}

@end

//
//  UIViewController+Intercept_FileUploadPane.m
//  WebView_FileUploadBug
//
//  Created by YLCHUN on 2017/6/13.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "UIViewController+Intercept_FileUploadPane.h"
#import <objc/runtime.h>

@interface _UIImagePickerController_IFUP : NSObject
{
  __weak id<UINavigationControllerDelegate,UIImagePickerControllerDelegate> _receiverDelegate;
}
@end
@implementation _UIImagePickerController_IFUP

-(instancetype)initWithReceiver:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)receiver {
    if (self) {
        _receiverDelegate = receiver;
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)imagePicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //拦截代码。。。
    NSLog(@"didFinishPickingMediaWithInfo: %@", info.description);
    [_receiverDelegate imagePickerController:imagePicker didFinishPickingMediaWithInfo:info];
}

- (void)imagePickerController:(UIImagePickerController *)imagePicker didFinishPickingMultipleMediaWithInfo:(NSArray *)infos {
    //拦截代码。。。
    NSLog(@"didFinishPickingMultipleMediaWithInfo: %@", infos.description);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_receiverDelegate performSelector:_cmd withObject:imagePicker withObject:infos];
#pragma clang diagnostic pop
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id i = [super forwardingTargetForSelector:aSelector];
    if (!i && [_receiverDelegate respondsToSelector:aSelector]) {
        i = _receiverDelegate;
    }
    return i;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL b = [super respondsToSelector:aSelector];
    if (!b) {
        b = [_receiverDelegate respondsToSelector:aSelector];
    }
    return b;
}
@end

@interface UIImagePickerController ()
@property (nonatomic, strong) _UIImagePickerController_IFUP *ifup;
@end
@implementation UIImagePickerController (Intercept_FileUploadPane)
-(void)setIfup:(_UIImagePickerController_IFUP *)ifup {
    objc_setAssociatedObject(self, @selector(ifup), ifup, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(_UIImagePickerController_IFUP *)ifup {
    return objc_getAssociatedObject(self, @selector(ifup));
}

+(void)load {
    Class class = [self class];
    if (class) {
        SEL originalSelector = @selector(setDelegate:);
        SEL swizzledSelector = @selector(ifup_setDelegate:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

-(void)ifup_setDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)delegate {
    if ([delegate isKindOfClass:NSClassFromString(@"WKFileUploadPanel")]||[delegate isKindOfClass:NSClassFromString(@"UIWebFileUploadPanel")]) {
        self.ifup = [[_UIImagePickerController_IFUP alloc] initWithReceiver:delegate];
        [self ifup_setDelegate:(id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self.ifup];
        
//        id i = delegate;//测试代码
//        id B = [i valueForKeyPath:@"allowMultipleFiles"];
//        BOOL b = [B boolValue];
//        NSLog(@"FileUploadPanel_allowMultipleFiles: %@", b ? @"YES" : @"NO");
    }else{
        [self ifup_setDelegate:delegate];
    }
}

////单选多选监听（观察者）
////[self addObserver:self forKeyPath:@"allowsMultipleSelection" options:NSKeyValueObservingOptionNew context:nil];
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"allowsMultipleSelection"]) {
//       id B = [change valueForKey:@"new"];
//       BOOL b = [B boolValue];
//        NSLog(@"");
//    }
//}
@end

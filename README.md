# WebView_FileUploadBug
WKWebView, UIWebView &lt;<input type = "file" name = "file"> bug处理

### 说明
导致问题的html代码是这一句：<input type = "file" name = "file"> 调用app的UIDocumentMenuViewController控制
问题发生场景：VC presentViewController 显示 webVC；
或者VC presentViewController 显示NVC，webVC在NVC上
这时候在H5上的  input type = "file" 触发后会导致UIDocumentMenuViewController 和 pre出来的VC（显示webVC的界面）两个直接dismis掉，

### 分析处理
分心发现问题出在 WKFileUploadPanel（或 UIWebFileUploadPanel）内的 _dismisDisplayAnimated: 方法内
具体位置位于UIDocumentMenuViewController控制器关闭后的completion内触发。（具体可查阅 WebKit 源代码）

分析后发现 UIDocumentMenuViewController 和 webVC 之间并没有什么关系(pre关系)，只是和WKFileUploadPanel（或 UIWebFileUploadPanel） 有关系（delegate关系），基于这一点结合runtime切入，在presentViewController:animated: 时候对特殊UIDocumentMenuViewController进行标记，

然后dismissViewControllerAnimated:animated:时候的completion对标记对象进行区分处理，由于两次dismis是两个无关的vc顺序执行，所以用一个静态变量dismisFromFileUploadPanel 来标记是否是UIDocumentMenuViewController之后的dismis。
### 使用方式
将 UIViewController+Dismis 扩展添加到项目中即可

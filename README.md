# JSONToModel
工欲善其事，必先利其器，要想不加班、少加班，进行高效率工作，开发辅助工具是必不可少的,JSONToModel就是这样一款将JSON字符转换成model代码的开源工具。虽然网上有很多类似工具，但有个共同特点就是没有代码高亮，不美观，有的不支持网络请求将直接JSON数据生成模型代码。

其实整个工程主要技术要点在于如何使用Textkit进行代码高亮，模型生成功能就百来行代码，更像一个附加功能，但基本能满足正常开发需求。

功能及技术点:
 一、字典转模型代码
对粘贴JSON字符进行空格过滤处理，减少出现JSON数据不合法情况
支持网络请求JSON数据进行模型转换

二、代码高亮
使用正则匹配关键词进行代码高亮
使用highlight.jsjs库进行代码高亮
正则匹配与js库2种方式进行进行代码高亮，JavaScript有很多优秀的代码高亮库，以后用到代码高亮功能可以直接用js库来处理，在高亮效率，支持语言数量上都是一个不错的选择。
具体实现移步代码：JSONToModel

效果
![UC20180319_143058.png](http://7xr7vj.com1.z0.glb.clouddn.com/UC20180319_143233.png)

BugFIX：
使用TextKit进行代码高亮时，在iOS上正常，但在Mac OSX上会出现光标错位情况
https://stackoverflow.com/questions/35522394/nstextstorage-syntax-markdown
Why the Selection Changes When You Do Syntax Highlighting in a NSTextView and What You Can Do About It

Thanks:
AFNetworking
MJExtension
NSTextView-LineNumberView
highlightjs

下版本功能：
1、支持Swift模型代码生成
2、支持GET参数请求，支持POST请求
3、敬请期待

Github:https://github.com/huluo666/JSONToModel

相关：CSS转JSON

参考文档
https://github.com/objcio/issue-5-textkit
https://github.com/objcio/S01E91-rendering-markdown-with-syntax-highlighting

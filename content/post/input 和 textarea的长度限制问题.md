+++
author = "author"
date = "2016-01-28T21:48:40+08:00"
description = "input 和 textarea"
draft = false
keywords = ["javascript", "web"]
tags = ["javascript", "web"]
title = "input 和 textarea的长度限制问题"
topics = ["topic 1"]
type = "post"

+++

一些敏感的页面应用，对用户的输入都有较多的限制，长度便是其中之一。但是最近遇到一个长度限制的问题。HTML对 input 和 textarea都有maxlength 的属性，该属性的解释就是[允许输入字段的最大字符数](http://www.w3school.com.cn/tags/att_input_maxlength.asp)。这里说的字符数，对英文是完全没有问题的，能做到精确控制输入长度，但是汉字的长度就会有前后不一致的问题。

## 编码问题
互联网上使用最为广泛的就是UTF-8的编码方式，查看网页源码的时候基本上都能看到字符集的编码设置：
```
<meta charset="utf-8">
```
UTF-8是Unicode的一种实现方式。是一种变长编码，想更多了解的可以看[这篇文章](http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)，基本上能让大家明白。所以造成这个问题的主因也是由于变长编码导致的。javascript把每个汉字当成一个字符，而在后台PHP是按照UTF-8计算，每个汉字由三个字节组成，故中文输入到了后台长度会变成字数的三倍。所以在输入框里面有中文的时候maxlength限制就不再可靠了。

## 精确获取字符长度
由于maxlength不再可靠，需要有方法获取任意输入的字节数。针对中文输入使用将其转码并使用特殊方法计算其长度便可达成精确控制输入长度的目的。**encodeURIComponent**方法是比较好用的：
```
The encodeURIComponent() function encodes a Uniform Resource Identifier (URI) component by replacing each instance of certain characters by one, two, three, or four escape sequences representing the UTF-8 encoding of the character (will only be four escape sequences for characters composed of two "surrogate" characters).
```
该方法能将UTF-8编码的输入文字转码成对应的多字节字符串。
例如：
```
encodeURIComponent('我的问题')
"%E6%88%91%E7%9A%84%E9%97%AE%E9%A2%98"
```
每个中文字转成三个字节冠以%开头。匹配出这样的pattern并计算长度，使用javascript的正则表达式:
```
/%[A-F\d]{2}/g
```
并临时替换成一个英文字符，那么长度就可以准确得到了：
```
encodeURIComponent('abc我的问题abc').replace(/%[A-F\d]{2}/g, 'i')
"abciiiiiiiiiiiiabc"
encodeURIComponent('abc我的问题abc').replace(/%[A-F\d]{2}/g, 'i').length
18
```
## textarea 中的换行符
与input相比，textarea还能输入回车换行，但是换行在javascript计算长度的时候却少计算一个字符，这样也会造成跟PHP后台不一致的情况，其实java后台也是一样的。
例如只有一个换行符的encode前端结果：
```
encodeURIComponent($('textarea').val())
"%0A"
```
而到了后台该换行符变成：**0D 0A**。
产生这个问题的原因是换行符在HTTP[传输的过程中发生转换](http://stackoverflow.com/questions/462348/string-length-differs-from-javascript-to-java-code)，由‘\n’变成‘\r\n’。
因此在计算textarea值时在遇到换行符时记得长度额外加1。

## 代码实现
既然问题原因找到了，解决的思路也基本清晰了，剩下的就是JS代码实现下了。
针对input：
```
    $("input").on('keydown keyup paste',function(){
        var $that = $(this),
        maxlength = $that.attr('maxlength');

        if($.isNumeric(maxlength) && maxlength > 0){
            var realLen = encodeURIComponent($that.val()).replace(/%[A-F\d]{2}/g, 'U').length;
            var currLen = $that.val().length;
            if (realLen > maxlength) {
                do {
                    $that.val($that.val().substr(0, currLen));
                    currLen --;
                } while (encodeURIComponent($that.val()).replace(/%[A-F\d]{2}/g, 'U').length > maxlength);
            }
        };
    });
```
针对textarea：
```
    $("textarea").on('keydown keyup paste',function(){
        var $that = $(this),
        maxlength = $that.attr('maxlength');

        if($.isNumeric(maxlength) && maxlength > 0){
            var realLen = encodeURIComponent($that.val()).replace(/%[A-F\d]{2}/g, 'U').length;
            var newLines = $that.val().match(/(\r\n|\n|\r)/g);

            if (newLines !== null) {
                realLen += newLines.length;
            }
            var currLen = $that.val().length;
            if (realLen > maxlength) {
                do {
                    $that.val($that.val().substr(0, currLen));
                    currLen --;
                    realLen = encodeURIComponent($that.val()).replace(/%[A-F\d]{2}/g, 'U').length;
                    newLines = $that.val().match(/(\r\n|\n|\r)/g);
                    if (newLines !== null) {
                        realLen += newLines.length;
                    }
                } while (realLen > maxlength);
            }
        };
    });
```
上述代码已完整测试，中文、英文、中英文混合、复制粘贴等等，都能按照maxlength的值精确控制用户输入的长度了。

## 总结
见微知著，看似不大的问题却涵盖很广的知识面。就是这样，注意细节问题，才能不断进步。厚积薄发，注意小问题，更不轻易放过，放过了小问题，对你来说就是大问题了。

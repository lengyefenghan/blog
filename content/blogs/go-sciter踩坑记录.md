---
title: "go-sciter踩坑记录"
date: 2021-03-23T13:39:08+08:00
draft: false
tags: ["sciter","golang"]
series: ["sciter"]
categories: ["golang"]
---

## 已经解决
1. css宽度100%异常问题： width: *; 用星号代替即可
2. 出现tis css html 等无法load //xx.xx error 161：
使用Go的filepathAbs获取绝对路径

``` go golang
path ,_ := filepath.Abs("html") //filepath.Abs(string) string error获取绝对路径
sciter.LoadHtml(html, path) //LoadHtml第二个参数填写html文件所在的文件夹的绝对路径
sciter.LoadFile(path+"xxx.html") //LoadFile用绝对路径获取文件名
```
另一个解决方案：
``` go golang
var html = `
  <style>
    {{css}}
  </style>
  <script type="text/tiscript">
    {{tis}}
  </script>
`
var tis = `xxxx`
var css = `xxx`

html = strings.Replace(html,"{{css}}",css,-1)
html = strings.Replace(html,"{{tis}}",tis,-1)

w.LoadHtml(html,"")
```
3. view.load(url:string[, now: bool]) : true/false 需要读取一个目录，可以通过获取win的AppData目录来写入配置文件，临时文件等等。view.load将会从url指定的路径读取一个html文件并加载.AppData文件夹下的Local下面新建文件夹就可以用于存放配置文件等，其中的Temp文件夹会被清理
``` go golang
package main

import (
    "fmt"
    "os"
    "runtime"
)

func UserHomeDir() string {
    if runtime.GOOS == "windows" {
        home := os.Getenv("HOMEDRIVE") + os.Getenv("HOMEPATH")
        if home == "" {
            home = os.Getenv("USERPROFILE")
        }
        return home
    }
    return os.Getenv("HOME")
}

func main() {
    homeDir := UserHomeDir()
    fmt.Println(homeDir + "\\AppData")
}
```

4. sciter中代码没错但是没法启动：请更新到开发版本
``` bash
go get -u github.com/sciter-sdk/go-sciter@master
```

5. 出现内存报错，例如：
``` bash
panic: runtime error: invalid memory address or nil pointer dereference
```
请检查函数返回的err是否处理，强制使用if判断err,当err为空的时候继续执行，否则照成不必要的错误

``` go golang
s,err := ioutil.ReadFile(path)
if err == nil {
    fmt.Println("s:",s)
}else {
    log.Printl(err.Error())
}
```
6. 部分情况下css文件中会通过url(xx.tis)的方法引入tis脚本，例如：
``` css
selector {
    prototype: ClassName url(file.tis);
    /* ... 其他CSS属性 */
}
```
其中有意思的是
<ul>
<li>
<ul>selector是一个有效的CSS选择器, 示例:
    <li>input[type=foo] { prototype: MyWidget; } </li>
    <li>foo { display:block; prototype: MyWidget; }</li>
    <li>widget { prototype: MyWidget; }</li>
</ul>
</li>
<li>ClassName是你的脚本类的名称;</li>
<li style="color:red;">url(file.tis)是包含该脚本类的脚本文件的url。如果脚本类是定义在文档本身的script节中的话，这个字段是可省略的。</li>
</ul>
最后红色字体的内容说明了，如果这个tis里面的内容包含在html里面的情况下，就不需要url引入组件，也就是可以通过上面的方式合并文件








## 站点配置

baseURL = "https://lengyefenghan.top/"
title = "lengyefenghan"
languageCode = "zh-cn"
hasCJKLanguage = true
# 版权信息（支持 Markdown）
copyright = "[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh)"

## 作者信息
[author]
    # 名字
    name = "冷夜枫寒"
    # 邮箱
    email = "lengyefenghan@outlook.com"
    # 座右铭或简介
    motto = "Dream it prossble!"
    # 头像
    avatar = "/icons/lengyefenghan-logo.png"
    # 网站（默认值：baseURL）
    website = "https://lengyefenghan.top/"
    # 推特
    #twitter = "lengyefenghan"

## 首页布局
    # MemE 主题有以下四种首页布局：
    # 1. poetry    诗意人生
    # 2. footage   视频片段
    # 3. posts     文章摘要
    # 4. page      普通页面

    homeLayout = "posts"

    ## 「诗意人生」
    # 诗句，支持 Markdown
    ###指引文件
    #homePoetry = ["霅溪湾里钓渔翁，舴艋为家西复东。","江上雪，浦边风，笑著荷衣不叹穷。","松江蟹舍主人欢，菰饭莼羹亦共餐。","枫叶落，荻花乾，醉宿渔舟不觉寒。","青草湖中月正圆，巴陵渔父棹歌连。","钓车子，掘头船，乐在风波不用仙。"]
    # 底部链接的内间距，单位：em
    homeLinksPadding = 1


## 站点信息

    # 站点的 LOGO
    siteLogo = "/icons/lengyefenghan-logo.png"
    # 说明：用于 JSON-LD、Open Graph

    # 站点的描述
    siteDescription = "冷夜枫寒，一个分享软件、知识的地方。"
    # 说明：用于 HTML 的头部元数据、JSON-LD、
    #      Open Graph、Atom、RSS
    # 站点的关键词

    siteKeywords = ["冷夜楓寒","软件分分享","冷夜枫寒","lengyefenghan"]
    # 说明：如果留空（[]），则会取站点的所有类别名、分
    #      区名（如果按分区分类）作为默认值

    # 站点的创建时间
    siteCreatedTime = "2018-07-20T20:17:43+00:00"
    # 注意：请保持此格式，更改数字

    # 站点的推特帐号
    #siteTwitter = "lengyefenghan"
    # 说明：用于 Twitter Cards

## Google Analytics

### 说明：仅在生产环境（production）下渲染

    <code> enableGoogleAnalytics = true </code>

    # 跟踪代码的类型
    trackingCodeType = "gtag"
    # 说明：gtag 或 analytics

    trackingID = "UA-166082839-1"


    ######################################
    # Google Site Verification

    googleSiteVerification = ""


    ######################################
    # Google AdSense

    # 说明：仅在生产环境（production）下渲染

    googleAdClient = "ca-pub-4304291357650629"

    ## 自动广告
    enableGoogleAutoAds = true

    ## 广告单元
    enableGoogleAdUnits = true
    googleAdSlot = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"

    ######################################
    # 文章目录

    # 是否开启（全局设置）
    enableTOC = true
    # 说明：文章的 Front Matter 中的 `toc`
    #      的优先级高于此处

    # 是否显示目录标题
    displayTOCTitle = true

    # 是否链接文章的分节标题到目录
    linkHeadingsToTOC = true
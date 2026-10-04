[README.md](https://github.com/user-attachments/files/33021709/README.md)
# 藏物账（CangWuZhang）# CangWuZhang (藏物账)

**Track what you own, and what it actually costs you per day.**

An asset-tracking app for everything you buy: gadgets, sneakers, figures, gold, Moutai, luxury goods, game accounts, memberships. Log it when you buy it, and the app works out what it costs you per day. When you sell something, it shows the real profit or loss, so you can see where your money actually goes and cut down on impulse buys.

Built natively with **SwiftUI + SwiftData**, iOS 17+. All data stays on your phone. Nothing is uploaded to any server.

<img width="1279" height="2781" alt="acbcb80c8fe598a67313385dd3ee3199" src="https://github.com/user-attachments/assets/00865c82-bfdf-497a-aae0-f6ecb5940bb2" />


## What it does

**Log anything you own**
Gadgets, sneakers, figures, luxury goods, gold, Moutai, game accounts, memberships, and more. Record the purchase price, the date and a note, then tag items to group and filter them.

**On-device AI cutout**
Take a photo or pick one from your library. Apple's Vision framework finds the subject and removes the background entirely on device, turning each item into a transparent sticker for your own digital display case. Fully offline, no third-party service, no cost.

**Three cost models: not everything should be measured by daily cost**
A core idea in this version. Things hold their value in different ways, so the app splits them into three models. A default is picked automatically from the category, and you can override it:

| Cost model | Best for | How it works |
|---|---|---|
| Ongoing use | Gadgets, sneakers, luxury goods, memberships | Daily cost = purchase price ÷ days used. The longer you keep it, the cheaper it gets. |
| One-off consumption | Opened Moutai, food and consumables | No daily cost. Just the purchase price and a consumed / not-consumed state. |
| Investment / collection | Gold, sealed collectible Moutai | No daily cost. You enter a current value instead, and the app calculates unrealised profit and percentage change. |

**Asset status tracking**
Active → Idle → Sold (or not-consumed → consumed for consumables). Follows an item through its whole life, from purchase to sale.

**Daily cost and depreciation** (the core of the ongoing-use model)
Daily cost is calculated automatically as purchase price ÷ days used. You can set a target daily cost and watch a payback progress bar on the detail page. A trend chart shows the daily cost falling over time, so you can see an item becoming better value the longer you keep it.

**Sell-off profit and loss review**
Enter the sale price and the app calculates total profit or loss and the real daily depreciation. For the impulse buys you barely used, the numbers after selling make the real cost obvious.

**Dashboard**
Total value held (collectibles at current value, everything else at purchase price), item counts by status, a category breakdown pie chart, holding-duration distribution, a 12-month spending trend, resale retention rate, and unrealised gains on collected items.

**Tag management**
Under "Me" → "Tag management" you can see every tag you have used and how many items carry it, and rename (merging duplicates) or delete them.

**Sticker view / list view**
The main display case switches between two views, with filters by status, category and tag, plus search by name or tag.

## Running it on your Mac

The project was actually created with Xcode's built-in "New Project" wizard, not through the XcodeGen flow described in `project.yml`. That file was a fallback from the original handover; the generated `Cangwuzhang.xcodeproj` is what is in use.

1. Double-click `Cangwuzhang.xcodeproj` to open it in Xcode (open the project, not the outer folder).
2. Select the `Cangwuzhang` target on the left → **Signing & Capabilities**, and pick your own Apple ID as the Team. A free personal account is enough for on-device debugging; you will need to re-sign every 7 days.
3. Pick a simulator (iPhone 15 or later, iOS 17+) or plug in a device, then ⌘R to run. Use ⌘B to check for compile errors.
4. The first time you install on a real device, trust your developer identity under Settings → General → VPN & Device Management.

If you ever need to rebuild the project on a new Mac, or the `.xcodeproj` gets corrupted, create a new SwiftUI + SwiftData app project following the fields in `project.yml` (any Bundle ID; set Minimum Deployment to iOS 17), drag in the `.swift` files under `CangWuZhang/` keeping the current folder structure, and add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to Info.

## Project structure

```
Cangwuzhang/
  Cangwuzhang.xcodeproj/        # the Xcode project actually in use
  CangWuZhang/
    App/CangWuZhangApp.swift    # app entry point + SwiftData container
    Models/                     # Item model, category / status / cost-model enums
    Utilities/                  # cost calculation, AI cutout, formatters
    Views/
      RootTabView.swift         # three tabs: Showcase / Dashboard / Me
      Showcase/                 # display case (sticker grid + list + filters)
      AssetDetail/               # detail page, sell review, current value update
      AddEdit/                  # add / edit form, photo picker, tag input
      Dashboard/                 # dashboard charts
      Settings/                  # "Me": tag management + roadmap
    Assets.xcassets/
```

## What's next

Aligned with the roadmap inside the app's "Me" tab, roughly in priority order:

1. **Wishlist** — record things you want to buy, with an estimated price and estimated daily cost, and look at it before you buy.
2. **Data export / asset report** — export to PDF or a spreadsheet for backup, sharing, or a year-end review.
3. **iCloud sync** — automatic sync across devices. The plan is to swap `ModelConfiguration` for a CloudKit-enabled one and add the iCloud + CloudKit capability in Signing & Capabilities.

Further out, not yet scheduled:
- Auto-update current values for collectibles from second-hand market listings, instead of entering them by hand
- Export sticker cards as images for sharing on social platforms
- Batch tag editing and a tag-level statistics dashboard
- A home screen widget showing today's total daily cost at a glance

## Known limitations

- All data lives only on this device (SwiftData). Before switching phones or deleting the app, export your data (once that feature ships) or wait for iCloud sync.
- In "total value held", items on the ongoing-use and one-off models count at their purchase price, while collectibles count at the current value you enter by hand. The app does not look up market prices, so you need to update that value yourself from time to time.
- The Vision cutout (`VNGenerateForegroundInstanceMaskRequest`) depends on how clear the subject is in the photo. If it fails, the app falls back to the original image instead of blocking the entry flow.

---

# 藏物账（CangWuZhang）

一个类似"有数"的万物资产记录 App：数码、球鞋手办、黄金茅台、奢品、游戏账号、会员权益……
不管是什么东西，买入就录进来，App 会自动帮你算"这东西每天花了你多少钱"，
卖出后帮你复盘真实盈亏，让你看清自己的消费结构，减少冲动消费。

原生 **SwiftUI + SwiftData** 开发，iOS 17+，所有数据存在手机本地，不上传任何服务器。

## 这个 App 能做什么

**万物资产录入**
数码 / 球鞋 / 手办 / 奢品 / 黄金 / 茅台酒类 / 游戏账号 / 会员权益 / 其他，全品类都能录，
填买入价格、购买时间、备注，还能打自定义标签，方便分组筛选。

**AI 智能抠图**
拍照或从相册选照片，苹果 Vision 框架在手机本地自动识别主体、去掉背景，生成透明贴纸图，
拼成你的专属数字陈列柜。全程离线处理，不依赖任何第三方服务，也不用付费。

**计价方式：不是所有东西都该按"日均成本"算**
这是这版新加的一个关键概念。买回来的每件东西，价值兑现的方式不一样，所以拆成三种"玩法"，
录入时按分类自动给一个默认值，也能手动改：

| 计价方式 | 适合什么 | 怎么算 |
|---|---|---|
| 持续使用 | 数码、球鞋、奢品、会员权益 | 日均成本 = 买入价 ÷ 已用天数，越用越划算 |
| 一次性消耗 | 开瓶喝掉的茅台、吃喝一次性用品 | 不算日均成本，只看买入价和"未消耗 / 已消耗"状态 |
| 投资收藏 | 黄金、封存不开的收藏茅台 | 不算日均成本，改成记"现值"，自动算浮动盈亏和涨跌幅 |

**资产状态标记**
现役在用 → 退役闲置 → 已卖出（消耗型对应未消耗 → 已消耗），完整跟踪一件东西从买到卖 / 用完的全过程。

**日均成本 & 折旧核算**（持续使用型的核心玩法）
买入总价 ÷ 使用天数自动算日均成本；能设目标日均成本，详情页看回本进度条；
还有日均成本随时间下降的趋势曲线图，直观看到"这东西已经越用越值了"。

**闲置卖出盈亏复盘**
填入卖出价格，自动算出总盈亏、实际日均损耗。冲动消费买了没怎么用的东西，
卖掉之后能清楚看到真实亏了多少，帮你克制下一次剁手。

**资产总览数据看板**
持有资产总值（投资收藏型按现值算、其他按买入价算）、状态数量统计、分类占比饼图、
持有时长分布柱状图、近 12 个月消费趋势折线图、已卖出藏品保值率、投资收藏型的浮动盈亏汇总。

**标签管理**
"我的" → "标签管理" 里能看到所有用过的标签和各自挂了几件东西，支持重命名（合并同名标签）和删除。

**贴纸模式 / 列表模式**
"陈列柜"主界面两种视图切换，支持按状态、分类、标签筛选，还能搜索名称或标签。

## 在你的 Mac 上跑起来

项目实际是通过 Xcode 自带的 "New Project" 向导创建的（不是走 `project.yml` 里写的 XcodeGen 流程，
那份 `project.yml` 是最初交付时的备用方案，目前工程结构以已经生成的 `Cangwuzhang.xcodeproj` 为准）。

1. 双击 `Cangwuzhang.xcodeproj` 用 Xcode 打开（不是打开外层文件夹）。
2. 左侧选中 `Cangwuzhang` target → **Signing & Capabilities**，Team 选你自己的 Apple ID
   （免费个人账号即可在真机调试，7 天需要重新签一次）。
3. 顶部选择模拟器（iPhone 15 及以上、iOS 17+）或接上真机，⌘R 运行；
   改完代码用 ⌘B 编译检查有没有报错。
4. 首次在真机上装应用后，需要在手机「设置 → 通用 → VPN 与设备管理」里信任你的开发者身份，
   才能正常打开 App。

如果之后要在新 Mac 上重新搭这个项目、或者 `.xcodeproj` 出问题需要重建，
可以按 `project.yml` 里写的字段手动新建一个 SwiftUI + SwiftData 的 App 工程
（Bundle ID 随意，Minimum Deployment 选 iOS 17），把 `CangWuZhang/` 目录下的
`.swift` 文件按现有文件夹结构拖进去，再把 `NSCameraUsageDescription` /
`NSPhotoLibraryUsageDescription` 这两条相机相册用途说明加到 Info 里。

## 项目结构

```
Cangwuzhang/
  Cangwuzhang.xcodeproj/        # 实际使用的 Xcode 工程
  CangWuZhang/
    App/CangWuZhangApp.swift    # App 入口 + SwiftData 容器
    Models/                     # Item 模型、分类/状态/计价方式枚举
    Utilities/                  # 成本核算、AI 抠图、格式化工具
    Views/
      RootTabView.swift         # 三个 Tab：陈列柜 / 数据看板 / 我的
      Showcase/                 # 陈列柜（贴纸网格 + 列表 + 筛选）
      AssetDetail/               # 详情页、卖出复盘、更新现值
      AddEdit/                  # 录入 / 编辑表单、照片选择、标签输入
      Dashboard/                 # 数据看板图表
      Settings/                  # "我的"：标签管理 + 路线图
    Assets.xcassets/
```

## 下一轮迭代方向

跟"我的"页里的路线图对齐，按优先级大致是：

1. **心愿单**——记录想买的东西，预估价格和预估日均成本，下单前先看一眼，减少冲动消费。
2. **数据导出 / 资产报告**——导出 PDF 或表格，方便备份、分享或者年底盘点。
3. **iCloud 同步**——多设备自动同步，技术方案是把 `ModelConfiguration` 换成启用
   CloudKit 的配置，并在 Signing & Capabilities 里加 iCloud + CloudKit 能力。

更远一点、目前还没排期的想法：
- 投资收藏型现值能接入闲鱼 / 二手平台行情自动更新，而不是手动录入
- 贴纸卡片支持导出成图片分享到社交平台
- 标签管理支持批量编辑、标签维度的统计看板
- 桌面小组件，一眼看到今天的日均成本总览

## 已知限制

- 所有数据只存在这台手机本地（SwiftData），换机 / 删除 App 前记得先做数据导出（等这个功能上线）
  或者等 iCloud 同步做完。
- "持有资产总值"里，持续使用型 / 一次性消耗型按买入价计入，投资收藏型按你手动填的"现值"计入，
  现值需要自己不定期更新，App 不会自动查市场价。
- Vision 抠图（`VNGenerateForegroundInstanceMaskRequest`）依赖照片里主体是否清晰，
  识别失败时会自动退回用原图，不会阻断录入流程。



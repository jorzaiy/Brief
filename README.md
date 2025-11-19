# Brief - 鸿蒙新闻聚合应用

<div align="center">

一个简洁优雅的鸿蒙新闻聚合应用，基于 [newsnow](https://github.com/ourongxing/newsnow) API 构建

</div>

## ✨ 功能特性

- 📱 **三大频道** - 关注、最热、实时三种内容分类
- 🎯 **简洁设计** - 极简UI，专注阅读体验
- 🔄 **实时更新** - 一键刷新获取最新内容
- 🌐 **多源聚合** - 整合40+优质中文新闻源
- ⚡ **快速加载** - 优化的数据加载和展示

## 📸 截图

<!-- 可以在这里添加应用截图 -->

## 🚀 快速开始

### 环境要求

- DevEco Studio 4.0 或更高版本
- HarmonyOS SDK API 10 或更高版本
- Node.js 20+ (用于 newsnow 服务端)

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <your-repo-url>
   cd Brief
   ```

2. **打开项目**
   - 使用 DevEco Studio 打开项目
   - 等待依赖自动下载

3. **配置 API 地址**（可选）
   
   如需修改 newsnow API 服务器地址，编辑文件：
   ```
   entry/src/main/ets/common/network/newsService.ets
   ```
   
   修改第14行：
   ```typescript
   private static readonly DEFAULT_BASE_URL = 'https://your-newsnow-server.com';
   ```

4. **运行应用**
   - 连接鸿蒙设备或启动模拟器
   - 点击运行按钮

## 📖 使用说明

### 频道说明

#### 📌 关注频道
默认关注的优质内容源：
- 知乎热榜
- V2EX 最新分享
- GitHub Trending
- Hacker News

#### 🔥 最热频道
热门内容聚合：
- 知乎、微博、抖音
- 哔哩哔哩、百度热搜
- 今日头条

#### ⚡ 实时频道
实时快讯：
- 华尔街见闻快讯
- 财联社电报
- 格隆汇事件
- 金十数据
- IT之家

### 自定义频道

编辑 `entry/src/main/ets/common/models/ChannelManager.ets` 文件：

```typescript
// 修改关注频道的数据源
private static followedSources: string[] = [
  'zhihu',
  'v2ex-share',
  'github-trending-today',
  // 添加更多数据源...
];
```

支持的数据源 ID 请参考 [newsnow 文档](https://github.com/ourongxing/newsnow)。

## 🏗️ 项目结构

```
Brief/
├── entry/
│   └── src/
│       └── main/
│           ├── ets/
│           │   ├── common/
│           │   │   ├── models/
│           │   │   │   ├── NewsItem.ets          # 新闻数据模型
│           │   │   │   └── ChannelManager.ets    # 频道管理
│           │   │   └── network/
│           │   │       └── newsService.ets       # API 服务
│           │   ├── pages/
│           │   │   ├── Index.ets                 # 主页面
│           │   │   └── WebViewPage.ets           # 详情页
│           │   └── entryability/
│           ├── resources/                         # 资源文件
│           └── module.json5                       # 模块配置
└── README.md
```

## 🔧 技术栈

- **开发语言**: ArkTS
- **UI框架**: ArkUI
- **网络请求**: @ohos.net.http
- **数据源**: newsnow API

## 🌐 数据源

本应用使用 [newsnow](https://github.com/ourongxing/newsnow) 作为数据源，支持以下平台：

**科技**: V2EX, 知乎, IT之家, GitHub, Hacker News, Linux.do, NodeSeek  
**财经**: 华尔街见闻, 雪球, 财联社, 金十数据, 格隆汇  
**中国**: 微博, 哔哩哔哩, 抖音, 虎扑, 百度贴吧, 今日头条  
**世界**: 联合早报, 参考消息, 靠谱新闻, Steam

## 📝 开发说明

### 添加新的数据源

1. 在 `ChannelManager.ets` 中添加数据源 ID
2. 确保 newsnow 服务端支持该数据源
3. 重新编译运行

### 修改 UI 样式

主要样式定义在各个 `.ets` 文件中：
- 颜色、字体大小等直接在组件中定义
- 遵循简洁设计原则

### 调试技巧

查看日志输出：
```bash
hdc shell hilog | grep NewsService
hdc shell hilog | grep Index
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🙏 致谢

- [newsnow](https://github.com/ourongxing/newsnow) - 提供优秀的新闻聚合 API
- HarmonyOS - 提供强大的开发平台

## 📮 联系方式

如有问题或建议，欢迎通过 Issue 反馈。

---

**Enjoy reading! 📰**

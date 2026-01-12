# Portal

> 🚀 AI Status Monitor - macOS 菜单栏 AI 状态监控应用

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub release](https://img.shields.io/github/release/caspianchan31/Portal.svg)](https://github.com/caspianchan31/Portal/releases)
[![GitHub stars](https://img.shields.io/github/stars/caspianchan31/Portal.svg)](https://github.com/caspianchan31/Portal/stargazers)

## 📖 项目简介

Portal 是一款专为开发者设计的轻量级 macOS 菜单栏应用，用于**实时监控** IDE 中 AI 服务的运行状态。

### 为什么需要 Portal？

在使用 AI 辅助编程工具（如 Cursor、Antigravity 等）时，开发者常常面临以下困扰：

- ❓ **AI 是否在运行？** 不清楚 AI 服务当前状态
- 💰 **成本有多少？** 缺乏对 AI 调用费用的感知
- 📊 **使用情况如何？** 无法统计和优化 AI 使用习惯
- ⚡ **性能如何？** 不了解 AI 响应时间和效率

Portal 让这一切变得**透明、直观、可控**。

---

## ✨ 核心功能

### 🔍 实时状态监控

- **菜单栏图标**：一目了然的 AI 运行状态
  - 🟢 AI 运行中（带脉动动画）
  - ⚪ 空闲状态
  - 🟠 异常警告
- **多 IDE 支持**：同时监控多个 IDE 的 AI 服务
- **详细面板**：点击图标查看各 IDE 的实时状态

### 📊 统计与分析

- **调用次数统计**：按小时/天/周/月查看 AI 使用情况
- **耗时分析**：了解每次 AI 调用的响应时间
- **成本估算**：基于 API 定价预估使用费用
- **可视化图表**：直观展示使用趋势

### 🔔 智能提醒

- **异常检测**：API 错误或超时自动提醒
- **成本预警**：超出预算阈值时通知
- **长时间运行提醒**：单次请求超时提醒

### 🎨 原生体验

- **macOS 原生设计**：完美融入系统
- **深色模式支持**：自动适配系统主题
- **低资源占用**：内存 < 50MB，CPU < 5%
- **隐私优先**：所有数据仅本地存储

---

## 🚀 快速开始

### 系统要求

- macOS 13.0 (Ventura) 或更高版本
- 支持的 IDE：
  - ✅ Cursor
  - ✅ Antigravity
  - 🔜 VS Code with Copilot（开发中）
  - 🔜 JetBrains with AI Assistant（开发中）

### 安装

#### 方式 1：下载预编译版本（推荐）

```bash
# 从 GitHub Releases 下载最新版本
# https://github.com/caspianchan31/Portal/releases/latest

# 解压并拖拽到 Applications 文件夹
# 首次运行需要在系统设置中允许该应用
```

#### 方式 2：从源码编译

```bash
# 克隆仓库
git clone https://github.com/caspianchan31/Portal.git
cd Portal

# 使用 Xcode 打开项目
open Portal.xcodeproj

# 在 Xcode 中构建并运行
```

### 初次使用

1. **启动应用**：打开 Portal，菜单栏会出现图标
2. **授予权限**：
   - 网络监控权限（用于检测 AI API 调用）
   - 文件访问权限（用于读取 IDE 日志）
3. **配置 IDE**：应用会自动检测已安装的 IDE
4. **开始监控**：打开 IDE 使用 AI 功能，Portal 会自动显示状态！

---

## 📚 文档

- **[产品需求文档 (PRD)](./docs/AI_Status_Monitor_PRD.md)** - 完整的产品设计和技术规划
- **用户指南** - 🚧 开发中
- **开发者文档** - 🚧 开发中
- **API 文档** - 🚧 开发中

---

## 🤝 参与贡献

我们非常欢迎社区贡献！无论是报告 bug、提出功能建议，还是提交代码，都是对项目的巨大帮助。

### 如何贡献

1. 📖 阅读 [贡献指南](./CONTRIBUTING.md)
2. 🍴 Fork 本仓库
3. 🌿 创建特性分支 (`git checkout -b feature/amazing-feature`)
4. 💻 提交你的改动 (`git commit -m 'Add amazing feature'`)
5. 📤 推送到分支 (`git push origin feature/amazing-feature`)
6. 🎉 创建 Pull Request

### 开发路线图

- [x] MVP 框架搭建
- [x] Cursor IDE 监控支持
- [x] Antigravity IDE 监控支持
- [ ] 统计分析功能
- [ ] 通知系统
- [ ] VS Code 支持
- [ ] JetBrains 支持
- [ ] 插件系统（允许第三方 IDE 接入）
- [ ] 跨平台支持（Windows、Linux）

### 贡献者

<a href="https://github.com/caspianchan31/Portal/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=caspianchan31/Portal" />
</a>

---

## 📄 许可证

本项目基于 [Apache License 2.0](./LICENSE) 开源。

这意味着：
- ✅ 商业使用
- ✅ 修改源码
- ✅ 分发
- ✅ 专利授权
- ✅ 私人使用

但需要：
- 📝 包含许可证和版权声明
- 📝 声明对代码的修改

---

## 💬 联系方式

- **GitHub Issues**: [报告问题或提出建议](https://github.com/caspianchan31/Portal/issues)
- **GitHub Discussions**: [参与讨论](https://github.com/caspianchan31/Portal/discussions)
- **作者**: [@caspianchan31](https://github.com/caspianchan31)

---

## 🌟 Star History

如果这个项目对你有帮助，欢迎给我们一个 Star ⭐！

[![Star History Chart](https://api.star-history.com/svg?repos=caspianchan31/Portal&type=Date)](https://star-history.com/#caspianchan31/Portal&Date)

---

## 🙏 致谢

感谢所有为本项目做出贡献的开发者！

特别感谢：
- [Cursor](https://cursor.sh/) - 启发本项目的优秀 AI IDE
- [Antigravity](https://antigravity.dev/) - Google 的 AI 编程助手
- macOS 开发者社区

---

<div align="center">

**[⬆ 回到顶部](#portal)**

_本项目正在积极开发中，欢迎关注和参与！_

Made with ❤️ by [@caspianchan31](https://github.com/caspianchan31)

</div>

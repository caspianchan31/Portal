# 贡献指南

感谢您对 Portal 项目的关注！我们欢迎各种形式的贡献，包括但不限于：

- 🐛 报告 Bug
- 💡 提出新功能建议
- 📝 改进文档
- 🔧 提交代码修复或新功能
- 🌍 翻译文档

---

## 🚀 快速开始

### 开发环境设置

1. **克隆仓库**

```bash
git clone https://github.com/caspianchan31/Portal.git
cd Portal
```

2. **安装依赖**

```bash
# 如果有 Swift Package Manager 依赖
# Xcode 会自动处理

# 如果使用 CocoaPods
# pod install
```

3. **打开项目**

```bash
open Portal.xcodeproj
# 或者如果使用 workspace
# open Portal.xcworkspace
```

---

## 🐛 报告 Bug

如果您发现了 bug，请[创建 Issue](https://github.com/caspianchan31/Portal/issues/new?template=bug_report.yml) 并提供以下信息：

### Bug 报告模板

- **问题描述**：清晰简洁地描述问题
- **复现步骤**：
  1. 第一步...
  2. 第二步...
  3. 出现错误...
- **预期行为**：应该发生什么
- **实际行为**：实际发生了什么
- **环境信息**：
  - macOS 版本：
  - Portal 版本：
  - IDE 及版本（如 Cursor 0.42.0）：
- **截图/日志**：如果可以，请提供截图或错误日志

### 检查清单

在提交 Bug 报告前，请确认：

- [ ] 已搜索[现有 Issues](https://github.com/caspianchan31/Portal/issues)，确认问题未被报告
- [ ] 使用的是最新版本的 Portal
- [ ] 已尝试重启应用和系统
- [ ] 提供了详细的复现步骤

---

## 💡 功能建议

我们欢迎新功能建议！请[创建 Feature Request](https://github.com/caspianchan31/Portal/issues/new?template=feature_request.yml)。

### 功能建议模板

- **功能描述**：描述您希望添加的功能
- **使用场景**：为什么需要这个功能？解决什么问题？
- **建议实现**：（可选）您认为如何实现这个功能
- **替代方案**：（可选）是否考虑过其他解决方案

---

## 🔧 提交代码

### Pull Request 流程

1. **Fork 仓库**

点击页面右上角的 "Fork" 按钮

2. **克隆您的 Fork**

```bash
git clone https://github.com/YOUR_USERNAME/Portal.git
cd Portal
```

3. **添加上游仓库**

```bash
git remote add upstream https://github.com/caspianchan31/Portal.git
```

4. **创建特性分支**

```bash
git checkout -b feature/your-feature-name
# 或者修复 bug
git checkout -b fix/bug-description
```

5. **进行开发**

- 编写代码
- 添加必要的注释
- 编写或更新测试（如果适用）

6. **提交变更**

```bash
git add .
git commit -m "feat: add amazing feature"
```

**提交信息规范**（使用 [Conventional Commits](https://www.conventionalcommits.org/)）：

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式调整（不影响功能）
- `refactor:` 代码重构
- `test:` 添加或修改测试
- `chore:` 构建或辅助工具变动

7. **推送到您的 Fork**

```bash
git push origin feature/your-feature-name
```

8. **创建 Pull Request**

- 访问您的 Fork 页面
- 点击 "New Pull Request"
- 填写 PR 描述（见下方模板）
- 提交 PR

### Pull Request 模板

```markdown
## 变更描述
<!-- 简要描述这个 PR 做了什么 -->

## 相关 Issue
<!-- 如果有相关 Issue，请引用，例如：Closes #123 -->

## 变更类型
<!-- 请勾选适用的选项 -->
- [ ] Bug 修复
- [ ] 新功能
- [ ] 文档更新
- [ ] 代码重构
- [ ] 性能优化
- [ ] 其他

## 测试
<!-- 描述您如何测试了这些变更 -->

## 截图
<!-- 如果有 UI 变更，请提供截图 -->

## 检查清单
- [ ] 代码遵循项目的编码规范
- [ ] 已添加必要的注释
- [ ] 已更新相关文档
- [ ] 所有测试通过
- [ ] 没有引入新的警告
```

---

## 📝 编码规范

### Swift 代码风格

遵循 [Swift Style Guide](https://google.github.io/swift/) 和以下约定：

1. **命名**
   - 类型名：PascalCase (`MyViewController`)
   - 变量/函数：camelCase (`fetchUserData()`)
   - 常量：camelCase (`maxRetryCount`)

2. **缩进**
   - 使用 4 个空格缩进
   - 不使用 Tab

3. **注释**
   ```swift
   /// 简要描述这个函数的作用
   ///
   /// - Parameters:
   ///   - param1: 参数1的描述
   ///   - param2: 参数2的描述
   /// - Returns: 返回值描述
   func myFunction(param1: String, param2: Int) -> Bool {
       // 实现...
   }
   ```

4. **访问控制**
   - 优先使用 `private` 和 `fileprivate`
   - 只在必要时使用 `public` 或 `open`

5. **错误处理**
   - 优先使用 `Result` 类型
   - 合理使用 `try?` 和 `try!`

### 代码审查要点

您的代码将被审查以确保：

- ✅ 功能完整且正确
- ✅ 代码清晰易读
- ✅ 遵循项目编码规范
- ✅ 有适当的错误处理
- ✅ 性能符合要求
- ✅ 没有内存泄漏

---

## 🧪 测试

### 运行测试

```bash
# 在 Xcode 中：Cmd + U
# 或使用命令行
xcodebuild test -scheme Portal -destination 'platform=macOS'
```

### 编写测试

为新功能添加单元测试：

```swift
import XCTest
@testable import Portal

class MyFeatureTests: XCTestCase {
    func testSomething() {
        // Given
        let sut = MyFeature()
        
        // When
        let result = sut.doSomething()
        
        // Then
        XCTAssertEqual(result, expectedValue)
    }
}
```

---

## 📖 文档贡献

### 改进文档

文档与代码同样重要！您可以：

- 修正拼写错误或语法问题
- 完善不清楚的说明
- 添加示例代码
- 翻译文档到其他语言

### 文档风格

- 使用清晰、简洁的语言
- 提供实际例子
- 使用截图辅助说明（如果适用）
- 保持格式一致

---

## 🌍 翻译

我们欢迎将文档翻译成其他语言！

### 如何贡献翻译

1. 在 `docs/i18n/` 目录下创建语言目录（如 `en/`, `ja/`）
2. 翻译 README 和其他文档
3. 提交 PR

### 翻译指南

- 保持术语一致（参考现有翻译）
- 不要使用机器翻译直接结果
- 保留代码示例和技术名词的原文

---

## 🏷️ Issue 和 PR 标签

我们使用以下标签来组织 Issues 和 PRs：

### Issue 标签

- `bug` - Bug 报告
- `enhancement` - 功能增强
- `documentation` - 文档改进
- `good first issue` - 适合新手的 Issue
- `help wanted` - 需要帮助
- `question` - 问题询问
- `wontfix` - 不会修复

### PR 标签

- `work in progress` - 开发中
- `needs review` - 需要审查
- `approved` - 已批准

---

## 📜 许可协议

提交代码即表示您同意将贡献内容以 [Apache License 2.0](./LICENSE) 开源。

---

## ❓ 需要帮助？

如果您在贡献过程中遇到问题：

- 📖 查看[文档](./docs)
- 💬 在 [GitHub Discussions](https://github.com/caspianchan31/Portal/discussions) 提问
- 📧 联系维护者：[@caspianchan31](https://github.com/caspianchan31)

---

## 🎉 感谢！

感谢您为 Portal 做出贡献！每一个 PR、Issue 或建议都让这个项目变得更好。

**Happy Coding! 🚀**

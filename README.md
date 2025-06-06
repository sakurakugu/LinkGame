# Qt和Cpp的连连看

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 项目简介

用 Qt(QML) 和 C++ 编写的连连看小游戏，这是数据结构课程的实践作业。游戏具有多种难度级别、排行榜系统和多语言支持。

![游戏截图](image/icon.png)

## 功能特点

- 经典连连看玩法，消除相同水果图案
- 三种难度级别：简单、普通、困难
- 支持自定义游戏参数
- 计时和计分系统
- 排行榜记录
- 多语言支持（中文、英文、日文）
- 主题切换
- 音效支持

## 技术栈

- C++
- Qt 6.8.3
- QML
- CMake 构建系统
- toml11（配置文件解析）

## 项目结构

- `cpp/` - C++源代码，包含游戏逻辑和配置
- `qml/` - QML界面文件
- `i18n/` - 国际化翻译文件
- `image/` - 图像资源
- `music/` - 音效资源
- `build/` - 构建输出目录

## 构建与运行

### 前提条件

- Qt 6.8.3 或更高版本
- CMake 3.16 或更高版本
- 支持C++17的编译器

### 构建步骤

#### 使用 Qt Creator 构建

1. 克隆项目到本地
   ```bash
   git clone https://gitcode.com/sakurakugu/LinkGame.git
   cd LinkGame
   ```

2. 使用 Qt Creator 打开并构建项目
   - 打开 Qt Creator
   - 选择 `文件` -> `打开文件或项目`
   - 选择 `CMakeLists.txt` 文件
   - 选择 `构建` -> `构建`
   - 选择 `运行` -> `运行`

#### 使用 CMake 构建

1. 克隆项目到本地
   ```bash
   git clone https://gitcode.com/sakurakugu/LinkGame.git
   cd LinkGame
   ```

2. 配置 VSCode
   - 在 VSCode 中，下载 Qt Extension Pack 和 CMake Tools 插件
   - 其次在插件设置中设置 Qt 路径
   - 然后按下 `Ctrl+Shift+P` 打开命令面板，输入 `CMake: Select a Kit` 并选择 `Qt-6.8.3-mingw_64`
   - 最后在终端中输入以下命令
   ```bash
   mkdir build
   cd build
   cmake ..
   ```

3. 构建项目
   - 按下 `Ctrl+Shift+P` 打开命令面板，输入 `CMake: Build Target` 按钮
   - 选择 `all` 选项
   - 等待构建完成

4. 运行游戏
   ```bash
   cd ./build
   ./appLinkGame
   ```

## 多语言支持

本游戏支持多种语言，包括中文、英文和日文。若要更新或添加新的翻译：

1. 生成翻译文件
   ```bash
   lupdate main.cpp qml/ cpp/ -ts ./i18n/qml_en.ts ./i18n/qml_zh_CN.ts ./i18n/qml_ja.ts
   ```

2. 使用Qt Linguist进行翻译编辑

3. 重新构建项目，翻译会自动被编译并添加到项目中

## 游戏玩法

1. 选择游戏难度（简单、普通或困难）或自定义游戏参数
2. 点击两个相同的图案，如果它们可以通过不超过两个弯折的连线相连，则会被消除
3. 消除所有图案即可获胜
4. 如果无法继续消除，可以使用"重排"功能

## 开发计划

请参见[TODO.md](TODO.md)文件，了解计划中的功能和改进。

## 贡献

欢迎提交问题报告和改进建议。如果你想贡献代码，请遵循以下步骤：

1. Fork 项目
2. 创建你的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启一个 Pull Request

## 许可证

本项目基于 MIT 许可证发布 - 查看 [LICENSE](LICENSE) 文件了解更多详情。

## 致谢

- [水果图标](https://www.iconfont.cn/search/index?searchType=icon&q=%E6%B0%B4%E6%9E%9C)
- [Qt](https://www.qt.io/)
- [toml11](https://github.com/ToruNiina/toml11) 库用于配置文件解析

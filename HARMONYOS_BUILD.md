# 鸿蒙 (HarmonyOS) 构建指南

本文档说明如何在本地构建鸿蒙版本的应用。

## 前置要求

1. **HarmonyOS SDK (DevEco Studio)**
   - 下载并安装 [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio)
   - 或安装 [Command Line Tools for OpenHarmony](https://developer.harmonyos.com/cn/develop/deveco-studio#download_cli)

2. **环境变量配置**
   ```bash
   # 添加到 ~/.zshrc 或 ~/.bash_profile
   export HOS_SDK_HOME=/path/to/harmonyos-sdk
   export PATH=$HOS_SDK_HOME/bin:$PATH
   ```

3. **验证环境**
   ```bash
   ohpm --version  # 鸿蒙包管理器
   hvigorw --version  # 鸿蒙构建工具
   ```

## 构建步骤

### 方式一：使用构建脚本（推荐）

```bash
# Release 构建（默认）
./build_harmonyos.sh

# Debug 构建
./build_harmonyos.sh debug
```

### 方式二：手动构建

```bash
# 1. 获取依赖
./ohos_sdk/bin/flutter pub get

# 2. 生成代码
./ohos_sdk/bin/flutter pub run build_runner build --delete-conflicting-outputs

# 3. 构建鸿蒙应用
./ohos_sdk/bin/flutter build ohos --release

# 4. 查找构建产物
find build/ohos -name "*.app" -o -name "*.hap"
```

## 构建产物

构建完成后，产物通常在以下位置：
- `build/ohos/outputs/` - 主要输出目录
- `ohos/.ohosapp/` - DevEco 项目输出

常见文件类型：
- `.app` - 应用包（类似 APK）
- `.hap` - HarmonyOS Ability Package
- `.har` - HarmonyOS Archive（库文件）

## 签名和打包

鸿蒙应用需要签名才能安装到设备：

1. **使用 DevEco Studio**
   - 打开 `ohos/` 目录
   - 配置签名证书
   - Build → Build Hap(s)/App(s) → Build App(s)

2. **命令行签名**（需要证书）
   ```bash
   # 使用 DevEco 提供的签名工具
   hap-sign-tool sign-app -keyAlias <alias> -keystorePath <path> \
     -inFile unsigned.hap -outFile signed.hap
   ```

## 常见问题

### Q: 提示 "No Hmos SDK found"
**A:** 需要安装 DevEco Studio 并配置 `HOS_SDK_HOME` 环境变量。

### Q: 构建失败，提示缺少工具
**A:** 确保以下工具已安装并在 PATH 中：
- `ohpm` (鸿蒙包管理器)
- `hvigorw` (鸿蒙构建工具)

### Q: 如何安装到鸿蒙设备？
**A:** 
1. 启用设备的开发者模式
2. 通过 USB 连接设备
3. 使用 DevEco Studio 的 Run 功能
4. 或使用命令: `hdc install signed.hap`

### Q: CodeMagic 能构建鸿蒙版本吗？
**A:** 目前不能。CodeMagic 不提供鸿蒙 SDK 环境，只能在本地或自托管 CI 中构建。

## 参考资源

- [HarmonyOS 开发者文档](https://developer.harmonyos.com/)
- [Flutter for HarmonyOS](https://github.com/flutter-community/flutter-ohos)
- [DevEco Studio 下载](https://developer.harmonyos.com/cn/develop/deveco-studio)

## CI/CD 集成

如果需要自动化构建，推荐使用：
- **自托管 Runner**（GitHub Actions, GitLab CI）
- **Docker 容器**（包含 HOS SDK）
- **本地 Jenkins**

示例 GitHub Actions 配置会在需要时提供。

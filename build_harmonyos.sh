#!/bin/bash

# HarmonyOS Build Script
# 用于本地构建鸿蒙应用
# Usage: ./build_harmonyos.sh [debug|release]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_SDK="$PROJECT_DIR/ohos_sdk"
BUILD_MODE="${1:-release}"  # Default to release

# Validate build mode
if [[ "$BUILD_MODE" != "debug" && "$BUILD_MODE" != "release" ]]; then
    echo -e "${RED}错误: 无效的构建模式 '$BUILD_MODE'${NC}"
    echo "用法: $0 [debug|release]"
    exit 1
fi

echo -e "${GREEN}=== 鸿蒙应用构建脚本 ===${NC}"
echo "项目目录: $PROJECT_DIR"
echo "Flutter SDK: $FLUTTER_SDK"
echo "构建模式: $BUILD_MODE"
echo ""

# Check if Flutter SDK exists
if [ ! -d "$FLUTTER_SDK" ]; then
    echo -e "${RED}错误: Flutter SDK 未找到: $FLUTTER_SDK${NC}"
    echo "请确保 ohos_sdk 目录存在"
    exit 1
fi

# Check if HarmonyOS SDK is configured
if [ -z "$HOS_SDK_HOME" ]; then
    echo -e "${YELLOW}警告: HOS_SDK_HOME 环境变量未设置${NC}"
    echo "请确保已安装 DevEco Studio 并配置环境变量"
    echo "例如: export HOS_SDK_HOME=/path/to/harmonyos-sdk"
    echo ""
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 1: Clean previous builds
echo -e "${GREEN}[1/5] 清理之前的构建...${NC}"
rm -rf build/ohos
echo "✓ 清理完成"
echo ""

# Step 2: Get dependencies
echo -e "${GREEN}[2/5] 获取 Flutter 依赖...${NC}"
"$FLUTTER_SDK/bin/flutter" pub get
echo "✓ 依赖获取完成"
echo ""

# Step 3: Generate code (if needed)
echo -e "${GREEN}[3/5] 生成代码...${NC}"
if "$FLUTTER_SDK/bin/flutter" pub run build_runner build --delete-conflicting-outputs; then
    echo "✓ 代码生成完成"
else
    echo -e "${YELLOW}⚠ 代码生成失败或无需生成，继续...${NC}"
fi
echo ""

# Step 4: Build HarmonyOS app
echo -e "${GREEN}[4/5] 构建鸿蒙应用 ($BUILD_MODE)...${NC}"
if [ "$BUILD_MODE" = "release" ]; then
    "$FLUTTER_SDK/bin/flutter" build ohos --release
else
    "$FLUTTER_SDK/bin/flutter" build ohos --debug
fi
echo "✓ 构建完成"
echo ""

# Step 5: Locate and display build artifacts
echo -e "${GREEN}[5/5] 查找构建产物...${NC}"
OHOS_BUILD_DIR="$PROJECT_DIR/build/ohos/outputs"

if [ -d "$OHOS_BUILD_DIR" ]; then
    echo "构建产物位置: $OHOS_BUILD_DIR"
    echo ""
    echo "文件列表:"
    find "$OHOS_BUILD_DIR" -type f \( -name "*.app" -o -name "*.hap" -o -name "*.har" \) -exec ls -lh {} \;
    echo ""
    echo -e "${GREEN}✓ 构建成功!${NC}"
else
    echo -e "${YELLOW}警告: 未找到标准构建输出目录${NC}"
    echo "请检查 build/ 目录"
    ls -la "$PROJECT_DIR/build/" 2>/dev/null || echo "build 目录不存在"
fi

echo ""
echo -e "${GREEN}=== 构建流程完成 ===${NC}"
echo ""
echo "下一步:"
echo "1. 在 DevEco Studio 中打开 ohos/ 目录"
echo "2. 使用 DevEco Studio 签名和打包"
echo "3. 部署到鸿蒙设备或模拟器"

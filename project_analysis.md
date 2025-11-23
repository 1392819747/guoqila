# Expiry Tracker 项目分析报告

## 项目概览
- 项目名称：expiration_app（应用名称：Expiry Tracker）
- 技术栈：Flutter 跨平台应用框架
- 支持平台：Android、iOS、Windows、macOS、Linux、Web

## 核心功能
- 物品过期日期追踪和管理
- 分类管理（食品、乳制品、肉类、药品、化妆品等）
- 过期提醒通知（即将过期和已过期物品）
- 数据统计和可视化
- 多语言支持（英语、日语、韩语、中文）
- 图片和文本扫描功能（使用Google ML Kit）
- 黑暗模式支持
- AI助手功能

## 技术栈详情
### 主要依赖
- **状态管理**：Provider ^6.1.5+1
- **本地存储**：Hive ^2.2.3, hive_flutter ^1.1.0
- **通知服务**：flutter_local_notifications ^19.5.0
- **日期时间处理**：timezone ^0.10.1, intl ^0.20.2
- **UI组件**：google_fonts ^6.3.2, flutter_svg ^2.2.2, lucide_icons ^0.257.0
- **数据处理**：uuid ^4.5.2
- **图表库**：fl_chart ^1.1.1
- **多语言支持**：flutter_localizations
- **图像功能**：image_picker ^1.0.4, flutter_image_compress ^2.4.0
- **AI/ML功能**：google_mlkit_text_recognition ^0.15.0, google_mlkit_barcode_scanning ^0.14.1
- **权限管理**：permission_handler ^11.0.1
- **用户交互**：flutter_slidable ^4.0.3, reorderables ^0.6.0
- **数据共享**：share_plus ^7.2.1
- **首选项存储**：shared_preferences ^2.2.2

## 项目架构
项目采用了清晰的分层架构设计：

### 1. 数据模型层 (models/)
- **category.dart**：定义物品分类模型
- **item.dart**：定义物品数据模型，包含名称、过期日期、购买日期等属性

### 2. 状态管理层 (providers/)
- **item_provider.dart**：管理物品相关状态和业务逻辑
- **locale_provider.dart**：管理语言切换功能
- **settings_provider.dart**：管理应用设置

### 3. 服务层 (services/)
- **notification_service.dart**：处理本地通知功能
- **scan_service.dart**：提供扫描相关服务
- **scan_strategies.dart**：定义扫描策略
- **storage_service.dart**：管理数据存储和读取

### 4. 用户界面层 (ui/)
- **screens/**：主要页面组件
  - **home_screen.dart/home_view.dart**：主页视图
  - **add_item_screen.dart**：添加物品页面
  - **settings_screen.dart/settings_view.dart**：设置页面
  - **stats_screen.dart/statistics_view.dart**：统计页面
  - **multi_item_confirm_screen.dart**：多物品确认页面
- **theme/**：应用主题和样式
  - **app_colors.dart**：颜色定义
  - **app_text_styles.dart**：文本样式
- **widgets/**：可复用UI组件
  - 多种卡片组件（bold_item_card.dart, grid_item_card.dart等）
  - 导航组件（custom_bottom_nav_bar.dart）
  - 交互组件（quantity_control.dart, bold_dialog.dart等）

## 应用流程
1. 应用启动时初始化核心服务：
   - 存储服务初始化
   - 通知服务初始化并请求权限
   - 设置提供器初始化
2. 使用Provider注入各种状态管理
3. 支持多语言切换和明暗主题
4. 主页面展示物品列表和过期提醒

## 本地化支持
应用支持四种语言：
- 英语 (app_en.arb)
- 日语 (app_ja.arb)
- 韩语 (app_ko.arb)
- 中文 (app_zh.arb)

使用Flutter的官方本地化工具生成对应的本地化文件。

## 特色功能
1. **过期提醒系统**：支持即将过期和已过期物品的通知
2. **AI识别**：利用Google ML Kit实现文本和条码识别
3. **数据统计**：提供物品分类分布等统计信息
4. **多平台支持**：一套代码支持所有主流平台
5. **深色模式**：完整支持明暗主题切换

## 应用目的
帮助用户管理和追踪物品的有效期，减少浪费，特别是对于食品、药品等需要关注保质期的物品。通过提供过期提醒、分类管理和数据统计等功能，让用户能够更好地管理个人物品库存。
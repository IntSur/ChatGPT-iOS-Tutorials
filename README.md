# ChatGPT-iOS-Tutorials
# Swift Core Engines

Personal engineering training repository for Apple-native development.

This repository focuses on building **pure Swift core engines** that model real-world domains correctly, without UI, frameworks, or third-party dependencies.

The goal is to develop strong fundamentals in:
- Domain modeling
- Validation & invariants
- Controlled object creation
- Error-as-business design
- Apple-style API thinking

---

## 核心引擎说明（中文）

这是一个用于 **Apple 原生开发工程训练** 的个人仓库。

本仓库专注于构建 **纯 Swift 的核心业务引擎（Core Engine）**，  
通过脱离 UI、脱离框架、脱离第三方依赖的方式，  
系统性训练对真实业务领域的正确建模能力。

重点关注以下工程能力：

- 领域建模（Domain Modeling）
- 规则校验与不变量（Validation & Invariants）
- 受控对象创建（Factory / Controlled Creation）
- 将失败视为业务的一部分（Error as Business）
- 符合 Apple 设计哲学的 API 思维方式

---

## Engines / 引擎列表

### Task Engine
A task domain core engine focused on:
- Value-type modeling (`struct` / `enum`)
- Lifecycle states
- Validation & factory methods
- Explicit error handling (`throws`, `do-catch`)
- Rejecting invalid states at the system boundary

任务领域核心引擎，重点训练：
- 使用值类型进行业务建模
- 任务生命周期状态管理
- 校验规则与工厂方法
- 显式错误处理（throws / do-catch）
- 在系统边界拒绝非法状态

---

### Ledger Engine
Will focus on:
- Money & numeric correctness
- Time-based aggregation
- Precision & invariants
- Business-safe calculations

账务领域引擎，重点关注：
- 金额与数值正确性
- 时间维度统计与聚合
- 精度控制与业务不变量
- 面向真实业务的安全计算模型

---

### Image Metadata Engine
Will focus on:
- Metadata modeling
- Relationships & tagging
- Query abstraction
- Extensible domain design

图像元数据引擎，重点关注：
- 元数据结构设计
- 关联关系与标签系统
- 查询抽象能力
- 可扩展的领域模型设计

---

## Principles / 设计原则

- Pure Swift only（仅使用 Swift 标准能力）
- No UI（无 SwiftUI / UIKit）
- No third-party libraries（无第三方依赖）
- Explicit boundaries（明确系统边界）
- Errors are part of the domain（失败是业务的一部分）

---

## Status / 当前状态

This repository is an evolving engineering journal.  
Each engine is developed incrementally with daily notes and design decisions recorded.

这是一个持续演进的工程日志型仓库。  
每个引擎都会以阶段性实践与每日笔记的形式逐步完善，  
用于长期沉淀 Apple 原生开发的工程思维与设计经验。

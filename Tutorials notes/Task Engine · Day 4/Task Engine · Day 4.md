# **Task Engine · Day 4**  

## 主题：状态机抽离（State Machine）与 Transition Matrix  

⸻  

## **Day 4 的核心目标**  

Day 4 的目标不是新增功能，  
而是 **把“状态变化规则”从零散判断升级为一个可推理的系统**。  

从这一天开始，系统不再“碰巧正确”，  
而是 **规则明确、行为可验证**。  

⸻  

## **Day 4 的最终产出**  

1）状态变化规则被集中定义  
	•	状态是否可变，不再散落在 Task.updateStatus  
	•	统一交由 TaskStatus 的状态机规则判断  

2）Task.updateStatus 职责被极度简化  
	•	不再负责“定义规则”  
	•	只负责：  
	•	no-op 判断  
	•	冻结检查  
	•	委托状态机  
	•	返回新值  

3）引入 Transition Matrix  
	•	一次性验证所有 from → to 组合  
	•	系统行为可枚举、可观测、可复现  

⸻  

## **状态机抽离的设计原则**  

### **1）规则属于“状态”，而不是“对象”**  

状态是否可以转移，本质是 **状态自身的属性**，  
因此规则被定义在 TaskStatus 中：  
	•	pending 能转到哪里  
	•	completed 能转到哪里  
	•	archived 是否为最终态  

这种设计让规则：  
	•	集中  
	•	易读  
	•	易扩展  

⸻  

### **2）Task 不再充当“裁判”**  

在 Day 4 之前，Task.updateStatus 既修改数据，又判断合法性。  
Day 4 之后：  
	•	Task 只负责执行  
	•	状态机负责判断  

这是一次 **职责分离（Single Responsibility）** 的重要实践。  

⸻  

## **关于 no-op（同状态更新）的明确语义**  

Day 4 明确区分了三种结果：  

### 1）**no-op（同状态）**  

​	•	pending → pending  
​	•	completed → completed  
​	•	archived → archived  

这些操作：  
	•	不报错  
	•	不产生真实变化  
	•	直接返回原值  

这是对调用方友好、对并发/事件重复安全的设计。  

⸻  

### 2）**allowed（合法状态变化）**  

​	•	pending → completed  
​	•	completed → archived  
​	•	等等  

这些操作：  
	•	通过状态机校验  
	•	返回新的 Task  

⸻  

### 3）**rejected（非法状态变化）**  

​	•	archived → pending  
​	•	archived → completed  

这些操作：  
	•	明确抛出 invalidStatusTransition  
	•	系统状态不被污染  

⸻  

## **Transition Matrix 的工程意义**  

Transition Matrix 的作用不是“测试”，  
而是 **验证系统规则是否自洽**。  

通过枚举所有组合：  
	•	没有“隐含规则”  
	•	没有“拍脑袋判断”  
	•	系统行为一目了然  

这是构建复杂系统时非常重要的一步。  

⸻  

## **Day 4 中暴露的典型工程问题**  

曾出现的错误：  
	•	使用 newStatus.canTransition(to: newStatus)  
	•	而不是 status.canTransition(to: newStatus)  

这是一个：  
	•	编译能过  
	•	运行不崩  
	•	但**语义完全错误**的典型 bug  

Day 4 的修复过程强调了一个核心能力：  

**不是代码能跑就够了，**  
**模型是否正确才是关键。**  

⸻  

## **Day 4 的阶段性结论**  

如果说：  
	•	Day 1 定义了“Task 是什么”  
	•	Day 2 定义了“什么是非法”  
	•	Day 3 定义了“Task 如何变化”  

那么 Day 4 定义的是：  

**变化是否合理，以及规则是否自洽**  

从 Day 4 开始，Task Engine 已经具备：  
	•	可推理性  
	•	可验证性  
	•	可扩展性  

这是进入真实 App Core 的必要前提。  

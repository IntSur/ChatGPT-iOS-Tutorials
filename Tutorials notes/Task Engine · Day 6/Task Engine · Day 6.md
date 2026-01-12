**Task Engine · Day 6**  
  
主题：Swift 并发模型（Task / async / await / actor / @MainActor）的工程化使用  
  
⸻  
  
**Day 6 的核心目标**  
  
Day 6 的目标不是“多线程技巧”，而是：  
  
**在真实 iOS App 中，**  
**安全、清晰、可维护地使用并发。**  
  
重点解决三个问题：  
	•	并发执行怎么来？  
	•	共享状态怎么不乱？  
	•	UI 与后台如何协作？  
  
⸻  
  
**Swift 并发的三大核心抽象（总览）**  
  
Swift 并发并不是“线程 API”，而是三层抽象：  
	1.	**Task** —— 并发执行单元  
	2.	**async / await** —— 非阻塞等待模型  
	3.	**actor / @MainActor** —— 共享状态的并发安全  
  
它们各司其职，而不是互相替代。  
  
⸻  
  
**Task 是什么（不是线程）**  
  
Task 是 Apple 封装、优化并暴露给开发者的并发执行单元。  
  
关键认知：  
	•	Task ≠ 线程  
	•	Task 是轻量的  
	•	Task 可挂起 / 恢复  
	•	Task 由系统运行时调度到线程池执行  
	•	一个 Task 在执行过程中**不保证固定在线程上**  
  
一句话总结：  
  
**Task 决定“是否并发执行”。**  
  
⸻  
  
**async / await 是什么（不是并发）**  
  
async 描述的是函数能力，而不是执行方式。  
  
关键认知：  
	•	async ≠ 后台  
	•	async ≠ 新线程  
	•	async 只是声明：**这个函数允许被挂起**  
  
await 的真实含义是：  
  
**在这里挂起当前 Task，把执行权交还给调度系统。**  
  
一句话总结：  
  
**async 决定“能不能挂起”，**  
**await 决定“在哪里让出执行权”。**  
  
⸻  
  
**await 为什么必须存在（核心理解）**  
  
await 并不是“等结果”，而是：  
  
**跨 Actor 隔离边界时，**  
**显式让出执行权给调度系统。**  
  
典型场景：  
	•	后台 Task → 调用 @MainActor 方法  
	•	后台 Task → 调用 actor 的隔离方法  
  
如果没有 await：  
	•	后台线程会直接访问共享引用  
	•	会造成数据竞争（Data Race）  
  
一句话总结：  
  
**await 是进入并发安全区的“门”。**  
  
⸻  
  
**actor 是什么（并发安全的引用类型）**  
  
actor 是一种特殊的引用类型，用来保护共享可变状态。  
  
actor 的保证是：  
  
**任意时刻，只允许一个 Task 访问 actor 内部的可变状态。**  
  
特征：  
	•	不需要锁  
	•	不需要手动队列  
	•	所有外部访问必须 await  
	•	默认运行在后台执行器  
  
一句话总结：  
  
**actor 解决“并发下共享状态安全”的问题。**  
  
⸻  
  
**@MainActor 是什么（UI 世界的 actor）**  
  
@MainActor 是一个**全局 actor**，其执行器绑定在主线程。  
  
用途：  
	•	UI 状态  
	•	SwiftUI ViewModel / Store  
	•	被多个 View 观察的共享状态  
  
特征：  
	•	串行  
	•	主线程执行  
	•	与 SwiftUI 数据流天然匹配  
  
一句话总结：  
  
**@MainActor = 专门为 UI 服务的 actor。**  
  
⸻  
  
**Task / async / actor 的关系图**  
  
Task（并发执行）  
 └─ async 函数（可挂起）  
     └─ await（让出执行权）  
         └─ actor / @MainActor（串行访问共享状态）  
  
职责划分非常清晰：  
	•	Task：并发  
	•	async / await：挂起与恢复  
	•	actor：安全  
	•	@MainActor：UI 安全  
  
⸻  
  
**线程 ≠ Task（重要澄清）**  
  
在 Swift 并发语境中：  
	•	“线程”不是主要抽象  
	•	Task 不是绑定线程的  
	•	await 不会阻塞线程，只会挂起 Task  
  
可以理解为：  
  
**线程是运行资源，**  
**Task 是被调度的执行上下文。**  
  
⸻  
  
**iOS App 中的实际使用准则（工程级）**  
  
**必须放在 @MainActor 的：**  
	•	SwiftUI View / UIKit UI  
	•	ObservableObject / Store  
	•	UI 状态源（@Published / @State）  
  
**适合放在 Task（后台）的：**  
	•	网络请求  
	•	文件 IO  
	•	数据计算  
	•	与 UI 解耦的服务层  
  
## 典型黄金模式：  
UI 事件  
 ↓  
Task { }  
 ↓  
await async API  
 ↓  
@MainActor 写状态  
 ↓  
SwiftUI 自动刷新  
  
⸻  
  
**async API 的设计模式（Day 6 实战）**  
  
真实 App 中，推荐的 Store API 形态是：  
	•	Store 本身：@MainActor  
	•	提供 async 方法：  
	•	后台做耗时工作  
	•	最后回主线程写状态  
  
这实现了：  
	•	UI 不阻塞  
	•	状态安全  
	•	API 语义清晰  
  
⸻  
  
**@MainActor vs actor 的最终选择准则**  
	•	**状态是否直接驱动 UI？**  
	•	是 → @MainActor  
	•	否 → actor  
	•	**UI 不存在，这个状态是否仍然合理？**  
	•	是 → actor  
	•	否 → @MainActor  
  
一句话定型：  
  
**UI 状态在 MainActor，**  
**后台状态在 actor，**  
**并发执行用 Task。**  
  
⸻  

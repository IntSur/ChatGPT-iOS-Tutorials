**Task Engine · Day 5**  
  
主题：TaskStore（系统级状态管理）与生产级仓库设计  
  
⸻  
  
**Day 5 的核心目标**  
  
Day 5 的目标，是从“单个 Task 的演化”迈入“系统级状态管理”。  
  
在 Day 1–4 中，Task 已经具备：  
	•	清晰的数据结构  
	•	明确的业务规则  
	•	受控的状态机演化  
  
但仍然缺少一个关键角色：  
  
**谁来统一持有、管理、驱动这些 Task？**  
  
Day 5 引入的答案是：**TaskStore**。  
  
⸻  
  
**Task 与 TaskStore 的职责分工（极其重要）**  
  
**Task（struct）**  
	•	值类型  
	•	表达业务状态本身  
	•	负责：  
	•	校验规则  
	•	状态流转  
	•	值语义演化（返回新 Task）  
	•	不关心：  
	•	自己是否被存储  
	•	系统中还有没有其他 Task  
  
**TaskStore（class）**  
	•	引用类型  
	•	系统级状态容器  
	•	负责：  
	•	持有所有 Task  
	•	统一变更入口  
	•	查询、删除、替换  
	•	不关心：  
	•	Task 的业务规则细节  
  
一句话总结：  
  
**Task 是“世界的状态快照”，**  
**TaskStore 是“世界如何被管理和推进”。**  
  
⸻  
  
**为什么 TaskStore 必须是 class**  
  
TaskStore 具备以下特征：  
	•	需要共享（全系统唯一）  
	•	需要生命周期  
	•	多处需要看到同一份变化  
	•	不应被随意复制  
  
因此 TaskStore 必须是引用语义（class），而 Task 保持值语义（struct）。  
  
这是 Swift / SwiftUI / Redux / Elm 体系中非常经典、成熟的分工。  
  
⸻  
  
**Day 5A：TaskStore 的基础能力**  
  
**1）持有任务集合**  
	•	内部使用 [Task]  
	•	对外只读（private(set)）  
	•	所有修改必须通过 Store 的 API  
  
**2）基础操作能力**  
	•	add：添加新 Task  
	•	update：按 id 替换 Task  
	•	get：按 id 获取（Optional）  
	•	require：按 id 获取，找不到抛错  
	•	remove：按 id 删除，找不到抛错  
  
Store 的设计原则是：  
  
**不 silent fail，所有系统级失败都应显式抛出。**  
  
⸻  
  
**查询（Query）能力**  
  
TaskStore 提供系统级查询接口，例如：  
	•	按状态查询  
	•	按 tag 查询  
  
这些查询：  
	•	只读  
	•	不改变系统状态  
	•	基于 Store 当前持有的最新数据  
  
这是系统级“读模型”的起点。  
  
⸻  
  
**Day 5A 的关键升级：Store 驱动更新（apply）**  
  
Day 5A 的核心设计突破是引入：  
  
**apply(id:transform:)**  
  
设计动机：  
	•	避免外部持有过期 Task  
	•	所有变更基于 Store 内“最新版本”  
	•	统一系统写入口  
  
变更流程变为：  
  
1）Store 根据 id 找到当前 Task  
2）调用 transform（领域规则仍在 Task 内）  
3）将返回的新 Task 替换写回 Store  
4）返回最终 Task  
  
这是一个完整、可控、可追踪的系统级更新流程。  
  
⸻  
  
**Day 5A+：生产级仓库设计升级**  
  
**1）明确失败语义（StoreError）**  
  
引入 StoreError：  
	•	taskNotFound  
	•	taskAlreadyExists  
  
系统级错误不再被吞掉，而是明确暴露给调用者。  
  
⸻  
  
**2）add / update 的生产级语义**  
	•	add：  
	•	不允许重复 id  
	•	重复即抛错  
	•	updateOrThrow：  
	•	找不到即抛错  
	•	避免 silent overwrite  
  
这是仓库层稳定性的基础。  
  
⸻  
  
**3）多步 apply（链式变更）**  
  
引入可变参数版本的 apply：  
	•	一次 apply 内可执行多步变更  
	•	每一步基于上一步的结果  
	•	最终返回“链式演化后的最终 Task”  
  
例如：  
	•	更新状态  
	•	添加 tag  
	•	更新 note  
  
全部在 Store 内完成，保证一致性。  
  
⸻  
  
**apply 的工程意义（非常关键）**  
  
apply 的存在，意味着：  
	•	外部不再“改 Task”  
	•	外部只描述“我要怎么改”  
	•	Store 决定：  
	•	从哪里取数据  
	•	如何写回  
	•	失败如何处理  
  
这正是：  
	•	Redux reducer  
	•	Elm update  
	•	SwiftUI ViewModel 内部更新  
  
的共同思想。  
  
⸻  
  
**Day 5 的阶段性结论**  
  
如果说：  
	•	Day 1：定义对象  
	•	Day 2：定义边界  
	•	Day 3：定义演化  
	•	Day 4：定义规则系统  
  
那么 Day 5 定义的是：  
  
**系统级状态如何被集中管理与安全更新。**  
  
到 Day 5 结束，Task Engine 已具备：  
	•	清晰的领域模型（Task）  
	•	明确的状态机（TaskStatus）  
	•	可靠的仓库层（TaskStore）  
	•	可扩展的写入口（apply）  
  
这是一个**已经可以接 UI、并发、持久化的 Core**。  

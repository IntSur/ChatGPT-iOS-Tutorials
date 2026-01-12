**Task Engine · Day 7**  
  
**主题：持久化（Persistence）与生命周期安全**  
  
⸻  
  
**Day 7 的核心目标**  
  
Day 7 要解决的不是“能不能存文件”，而是：  
  
**让 App 的状态在真实 iOS 生命周期中：**  
**不丢、不卡、可升级。**  
  
⸻  
  
**Day 7 的最终成果（一句话）**  
  
**TaskStore 现在是一个：**  
**并发安全、自动持久化、生命周期可靠、可替换存储实现的状态系统。**  
  
⸻  
  
**一、为什么需要持久化（问题定义）**  
  
如果没有持久化：  
	•	App 重启 → 状态清空  
	•	系统杀进程 → 数据丢失  
	•	并发修改 → 最后一次操作可能没保存  
  
Day 7 解决的是：  
	•	**状态跨 App 生命周期**  
	•	**最后一次操作不丢**  
	•	**不阻塞 UI**  
  
⸻  
  
**二、Step 1：最小可用持久化（JSON）**  
  
**设计目标**  
	•	可读  
	•	可 Debug  
	•	无魔法  
	•	不依赖 UI / Store  
  
**实现要点**  
	•	[Task] ↔ JSON file  
	•	存储位置：Documents/TaskEngine/tasks.json  
	•	Codable + ISO8601  
	•	原子写入（.atomic）  
  
**关键认知**  
  
**持久化组件本身不持有状态，只做转换。**  
  
⸻  
  
**三、Step 2：接入 TaskStore 生命周期（自动）**  
  
**启动自动加载（Bootstrap）**  
	•	bootstrapIfNeeded()  
	•	只执行一次  
	•	后台读盘 → MainActor 写入 tasks  
	•	SwiftUI 自动刷新  
  
**写操作自动保存**  
	•	add / remove / update / apply / replaceAll  
	•	每次有效修改都会触发 scheduleSave()  
  
**debounce 的目的**  
	•	合并短时间内的多次修改  
	•	减少 IO  
	•	节省电量  
	•	不影响 UI 响应  
  
⸻  
  
**四、Step 3.1：让持久化错误“可观测”**  
  
**问题**  
	•	try? 会吞掉错误  
	•	出错时 UI / 开发者完全无感知  
  
**解决方案**  
	•	@Published lastPersistenceError  
	•	后台写盘失败 → 回 MainActor 记录错误  
  
**关键认知**  
  
**生产系统里，沉默失败 = 隐性 bug。**  
  
⸻  
  
**五、Step 3.2：flushNow 的真正目的（非常重要）**  
  
**debounce 的天然风险**  
	•	用户刚操作完  
	•	debounce 还没到时间  
	•	App 切后台 / 被系统杀掉  
	•	**最后一次修改丢失**  
  
**flushNow 的作用**  
	•	取消 pending debounce  
	•	立刻把当前状态写盘  
	•	用在关键生命周期节点  
  
**触发时机**  
	•	scenePhase == .background  
	•	App 即将被冻结或终止  
  
**一句话总结**  
  
	•	scheduleSave()：**日常省 IO**  
	•	flushNow()：**关键时刻保命**  
  
⸻  
  
**六、Step 3.3：Repository 抽象的真正目的**  
  
**问题**  
  
如果 TaskStore 直接依赖：  
  
TaskPersistence.load / save  
那么：  
	•	TaskStore 与 JSON 文件方案强绑定  
	•	升级 SwiftData / Cloud 会牵一发而动全身  
  
**Repository 的作用**  
	•	把“存储实现细节”抽离  
	•	TaskStore 只依赖稳定接口  
  
protocol TaskRepository {  
    func load() throws -> [Task]  
    func save(_ tasks: [Task]) throws  
}  
  
**当前实现**  
	•	FileTaskRepository（struct，无状态）  
  
**未来升级**  
	•	SwiftDataTaskRepository  
	•	CloudTaskRepository  
	•	TaskStore / SwiftUI **无需改动**  
  
**关键认知**  
  
**Repository 解决的不是“现在怎么存”，**  
**而是“未来怎么不返工”。**  
  
⸻  
  
**七、为什么 FileTaskRepository 用 struct**  
	•	无状态  
	•	无身份需求  
	•	只是行为集合  
	•	并发环境下语义清晰  
  
选型口诀：  
	•	**无状态依赖 → struct**  
	•	**有共享可变状态 → actor（优先）/ class**  
  
  
**八、Day 7 的整体系统形态（最终脑图）**  
**SwiftUI**  
**  ↓**  
**@MainActor TaskStore**  
**  - 业务规则**  
**  - 状态机**  
**  - 自动 save**  
**  - lifecycle flush**  
**  ↓**  
**TaskRepository（抽象）**  
**  ↓**  
**FileTaskRepository（当前）**  
**  ↓**  
**JSON / Disk**  
  
**九、Day 7 结束时你已经掌握的能力**  
	•	iOS 生命周期下的可靠持久化  
	•	debounce + flush 的工程组合  
	•	并发与 IO 的正确分工  
	•	为未来存储升级预留结构  

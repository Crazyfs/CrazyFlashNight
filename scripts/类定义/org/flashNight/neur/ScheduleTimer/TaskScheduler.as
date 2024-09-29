import org.flashNight.naki.DataStructures.*;
import org.flashNight.neur.ScheduleTimer.*;
import org.flashNight.neur.EventBus.*;

/**
 * TaskScheduler 类负责管理和调度任务。
 * 它订阅帧更新事件，并在每帧更新时执行相应的任务。
 */
class org.flashNight.neur.ScheduleTimer.TaskScheduler {
    // 属性
    private var tasks:Object;           // 定时任务哈希表
    private var zeroFrameTasks:Object;  // 零帧任务哈希表
    private var taskIDCounter:Number;   // 任务 ID 计数器
    private var scheduleTimer:CerberusScheduler; // 调度器定时器
    private var eventBus:EventBus;      // 事件总线实例

    // 配置参数
    private var singleWheelSize:Number;
    private var multiLevelSecondsSize:Number;
    private var multiLevelMinutesSize:Number;
    private var precisionThreshold:Number;
    private var frameRate:Number;
    private var millisecondsPerFrame:Number;

    // 构造函数
    public function TaskScheduler(eventBus:EventBus) {
        this.tasks = {};
        this.zeroFrameTasks = {};
        this.taskIDCounter = 0;
        this.singleWheelSize = 150;
        this.multiLevelSecondsSize = 60;
        this.multiLevelMinutesSize = 60;
        this.precisionThreshold = 0.1;
        this.frameRate = 30;
        this.millisecondsPerFrame = 1000 / this.frameRate;
        this.scheduleTimer = new CerberusScheduler(); // 初始化调度器
        this.scheduleTimer.initialize(this.singleWheelSize,
                                      this.multiLevelSecondsSize, 
                                      this.multiLevelMinutesSize, 
                                      this.frameRate, 
                                      this.precisionThreshold);
        this.eventBus = eventBus;
        this.initialize();
    }

    // 初始化，订阅帧更新事件
    private function initialize():Void {
        this.eventBus.subscribe("FRAME_UPDATE", Delegate.create(this, this.updateTasks));
    }

    // 添加新任务
    public function addTask(action:Function, intervalTime:Number, repeats:Number, ...params):Number {
        // 输入验证
        if (typeof action !== "function") {
            throw new Error("Invalid action provided. Expected a function.");
        }
        if (isNaN(intervalTime) || intervalTime < 0) {
            throw new Error("Invalid intervalTime provided. Expected a non-negative number.");
        }

        var taskID:Number = ++this.taskIDCounter;
        var intervalFrames:Number = Math.ceil(intervalTime * this.millisecondsPerFrame);
        
        // 实例化 Task 类
        var task:Task = new Task(taskID, action, intervalFrames, repeats, params);
        
        if (intervalFrames <= 0) {
            this.zeroFrameTasks[taskID] = task;
        } else {
            task.node = this.scheduleTimer.evaluateAndInsertTask(taskID, intervalFrames);
            this.tasks[taskID] = task;
        }

        return taskID;
    }

    // 添加单次执行任务
    public function addSingleTask(action:Function, intervalTime:Number, ...params):Number {
        if (intervalTime <= 0) {
            // 立即执行任务
            try {
                action.apply(null, params);
            } catch (error:Error) {
                trace("Error executing single task: " + error.message);
            }
            return null; // 表示任务已立即执行，无需任务 ID
        }
        return this.addTask(action, intervalTime, 1, params);
    }

    // 添加循环（无限重复）任务
    public function addLoopTask(action:Function, intervalTime:Number, ...params):Number {
        return this.addTask(action, intervalTime, true, params);
    }

    // 添加或更新任务
    public function addOrUpdateTask(obj:Object, tagName:String, action:Function, intervalTime:Number, ...params):Number {
        if (!obj.taskIdentifiers) obj.taskIdentifiers = {};
        if (!obj.taskIdentifiers[tagName]) {
            obj.taskIdentifiers[tagName] = ++this.taskIDCounter;
        }

        var taskID:Number = obj.taskIdentifiers[tagName];
        var task:Task = this.tasks[taskID] || this.zeroFrameTasks[taskID];
        
        if (task) {
            // 更新任务属性
            task.action = action;
            task.intervalFrames = Math.ceil(intervalTime * this.millisecondsPerFrame);
            task.params = params;
            // 重置重复次数，如果需要的话
            // 这里假设重复次数保持不变，或根据需求调整

            // 重新调度任务
            if (task.intervalFrames <= 0) {
                if (this.tasks[taskID]) {
                    this.scheduleTimer.removeTaskByNode(task.node);
                    delete this.tasks[taskID];
                    this.zeroFrameTasks[taskID] = task;
                }
            } else {
                if (this.zeroFrameTasks[taskID]) {
                    delete this.zeroFrameTasks[taskID];
                    task.node = this.scheduleTimer.evaluateAndInsertTask(taskID, task.intervalFrames);
                    this.tasks[taskID] = task;
                } else {
                    this.scheduleTimer.rescheduleTaskByNode(task.node, task.intervalFrames);
                }
            }

            // 设置卸载回调，确保对象销毁时移除任务
            _root.常用工具函数.设置卸载回调(obj, Delegate.create(this, function() {
                this.removeTask(taskID);
                delete obj.taskIdentifiers[tagName];
            }));
        } else {
            // 如果任务不存在，则添加新任务
            taskID = this.addTask(action, intervalTime, 1, params);
            obj.taskIdentifiers[tagName] = taskID;
            
            // 设置卸载回调
            _root.常用工具函数.设置卸载回调(obj, Delegate.create(this, function() {
                this.removeTask(taskID);
                delete obj.taskIdentifiers[tagName];
            }));
        }

        return taskID;
    }

    // 更新和执行任务，每帧调用一次
    public function updateTasks():Void {
        // 处理定时任务
        var scheduledTasks:TaskIDLinkedList = this.scheduleTimer.tick();

        if (scheduledTasks != null) {
            var node:TaskIDNode = scheduledTasks.getFirst();
            while (node != null) {
                var taskID:Number = Number(node.taskID);
                var task:Task = this.tasks[taskID];
                
                if (task) {
                    this.executeTaskSafely(task);
                    this.handleTaskCompletion(task);
                }

                node = node.next;
            }
        }

        // 处理零帧任务
        for (var id in this.zeroFrameTasks) {
            var zeroFrameTask:Task = this.zeroFrameTasks[id];
            this.executeTaskSafely(zeroFrameTask);
            this.handleTaskCompletion(zeroFrameTask);
        }
    }

    // 安全地执行任务的动作，包含错误处理
    private function executeTaskSafely(task:Task):Void {
        try {
            task.execute();
        } catch (error:Error) {
            trace("Error executing task ID " + task.id + ": " + error.message);
            // 可选：根据需求移除任务或采取其他措施
            // this.removeTask(task.id);
        }
    }

    // 处理任务完成逻辑
    private function handleTaskCompletion(task:Task):Void {
        if (task.remainingRepeats !== true) {
            task.remainingRepeats--;
        }
        
        if (task.isComplete()) {
            delete this.tasks[task.id];
        } else {
            task.node = this.scheduleTimer.evaluateAndInsertTask(task.id, task.intervalFrames);
        }
    }

    // 移除任务
    public function removeTask(taskID:Number):Void {
        if (this.tasks[taskID]) {
            var task:Task = this.tasks[taskID];
            this.scheduleTimer.removeTaskByNode(task.node);
            task.destroy(); // 清理任务引用
            delete this.tasks[taskID];
        } else if (this.zeroFrameTasks[taskID]) {
            var zeroTask:Task = this.zeroFrameTasks[taskID];
            zeroTask.destroy(); // 清理任务引用
            delete this.zeroFrameTasks[taskID];
        }
    }

    // 延迟执行任务
    public function delayTask(taskID:Number, delayTime:Number):Boolean {
        var task:Task = this.tasks[taskID] || this.zeroFrameTasks[taskID];
        if (task) {
            if (isNaN(delayTime)) {
                task.waitFrames = delayTime === true ? Infinity : task.intervalFrames;
            } else {
                var delayFrames:Number = Math.ceil(delayTime * this.millisecondsPerFrame);
                task.waitFrames += delayFrames;
            }

            if (task.waitFrames <= 0) {
                if (this.tasks[taskID]) {
                    this.scheduleTimer.removeTaskByNode(task.node);
                    delete this.tasks[taskID];
                    this.zeroFrameTasks[taskID] = task;
                }
                // 已在零帧任务中，无需进一步处理
            } else {
                if (this.zeroFrameTasks[taskID]) {
                    delete this.zeroFrameTasks[taskID];
                    task.node = this.scheduleTimer.evaluateAndInsertTask(taskID, task.waitFrames);
                    this.tasks[taskID] = task;
                } else {
                    this.scheduleTimer.rescheduleTaskByNode(task.node, task.waitFrames);
                }
            }

            return true; // 延迟设置成功
        }  
        return false; // 任务未找到，延迟设置失败
    }

    // 销毁调度器，清理所有任务和引用
    public function destroy():Void {
        for (var taskID in this.tasks) {
            this.removeTask(Number(taskID));
        }
        for (var zeroTaskID in this.zeroFrameTasks) {
            this.removeTask(Number(zeroTaskID));
        }
        this.scheduleTimer.destroy(); // 假设 CerberusScheduler 类有 destroy 方法
        this.scheduleTimer = null;
        this.tasks = null;
        this.zeroFrameTasks = null;
        this.eventBus.unsubscribe("FRAME_UPDATE", this.updateTasks);
    }
}

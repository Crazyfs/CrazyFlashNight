import org.flashNight.neur.ScheduleTimer.*;
import org.flashNight.naki.DataStructures.*;
import org.flashNight.aven.Coordinator.EventCoordinator;

class org.flashNight.neur.ScheduleTimer.TaskManager {
    private var tasks:Object;                // 存储定时任务
    private var zeroFrameTasks:Object;       // 存储零帧任务
    private var frameRate:Number;            // 帧率 (fps)
    private var frameRatePerMillisecond:Number; // 每毫秒对应的帧数
    private var scheduler:CerberusScheduler; // 调度器实例
    private var taskIDCounter:Number;        // 自增任务ID计数器

    // 构造函数
    public function TaskManager(frameRate:Number, scheduler:CerberusScheduler) {
        this.tasks = {};
        this.zeroFrameTasks = {};
        this.frameRate = frameRate;
        this.frameRatePerMillisecond = this.frameRate / 1000; // 预计算每毫秒对应的帧数
        this.scheduler = scheduler;
        this.taskIDCounter = 0; // 初始化计数器
    }

    // 生成唯一的任务ID
    private function generateUniqueTaskID():String {
        var newTaskID:String = "task-" + (++this.taskIDCounter);
        if (newTaskID == null || newTaskID == "") {
            trace("TaskManager Error: Generated taskID is invalid.");
        }
        return newTaskID;
    }

    // 创建任务
    public function createTask(action:Function, intervalTime:Number, repeats:Number, params:Array):String {
        var taskID:String = this.generateUniqueTaskID();
        if (taskID == null || taskID == "") {
            trace("TaskManager Error: Generated taskID is invalid.");
            return null;
        }

        var intervalFrames:Number = Math.ceil(intervalTime * this.frameRatePerMillisecond); // 使用预计算的帧率转换

        // 创建任务对象
        var task:Task = new Task();
        task.initialize(taskID, action, intervalFrames, repeats, params);

        if (intervalFrames <= 0) {
            this.zeroFrameTasks[taskID] = task;
            trace("TaskManager: Task " + taskID + " created as zero-frame task.");
        } else {
            var insertedNode:TaskIDNode = this.scheduler.evaluateAndInsertTask(taskID, intervalFrames);
            if (insertedNode != null) {
                task.node = insertedNode;
                this.tasks[taskID] = task;
                trace("TaskManager: Task " + taskID + " created and scheduled.");
            } else {
                trace("TaskManager Error: Failed to schedule Task " + taskID);
                return null;
            }
        }

        return taskID;
    }

    // 创建或更新带标签的任务
    public function createOrUpdateTask(tag:String, object:Object, action:Function, intervalTime:Number, repeats:Number, params:Array):String {
        if (!object.taskIdentifiers) {
            object.taskIdentifiers = {};
        }
        
        if (!object.taskIdentifiers[tag]) {
            // 创建新任务
            var taskID:String = this.createTask(action, intervalTime, repeats, params);
            object.taskIdentifiers[tag] = taskID;
            return taskID;
        } else {
            // 更新现有任务
            var taskID:String = object.taskIdentifiers[tag];
            this.updateTask(taskID, action, intervalTime, params);
            return taskID;
        }
    }

    // 创建与对象生命周期绑定的任务
    public function createLifecycleTask(tag:String, object:Object, action:Function, intervalTime:Number, repeats:Number, params:Array):String {
        var self = this;
        var taskID:String = this.createOrUpdateTask(tag, object, action, intervalTime, repeats, params);
        if (taskID == null || taskID == "") {
            trace("TaskManager Error: Failed to create or update task with tag " + tag);
            return null;
        }

        // 使用 EventCoordinator 设置卸载回调，确保对象销毁时移除任务
        EventCoordinator.addUnloadCallback(object, function() {
            self.removeTask(taskID);
            delete object.taskIdentifiers[tag];
        });

        return taskID;
    }

    // 更新任务
    public function updateTask(taskID:String, action:Function, intervalTime:Number, params:Array):Void {
        var task:Task = this.getTask(taskID);
        if (task) {
            task.action = action;
            var newIntervalFrames:Number = Math.ceil(intervalTime * this.frameRatePerMillisecond); // 使用预计算的帧率转换
            task.intervalFrames = newIntervalFrames;
            task.params = params;

            trace("TaskManager: Task " + taskID + " updated with new interval " + intervalTime + "ms.");

            if (newIntervalFrames <= 0) {
                this.moveTaskToZeroFrame(taskID, task);
            } else {
                this.moveTaskToScheduler(taskID, task);
            }
        } else {
            trace("TaskManager Error: Update failed. Task " + taskID + " not found.");
        }
    }

    // 删除任务
    public function removeTask(taskID:String):Void {
        var task:Task = this.getTask(taskID);
        if (task) {
            if (task.node != null) {
                this.scheduler.removeTaskByNode(task.node);
                trace("TaskManager: Task " + taskID + " removed from scheduler.");
                task.node = null; // 清除节点引用
            }
            delete this.tasks[taskID];
            delete this.zeroFrameTasks[taskID];
            trace("TaskManager: Task " + taskID + " destroyed and removed.");
        } else {
            trace("TaskManager Warning: Remove failed. Task " + taskID + " not found.");
        }
    }

    // 获取任务
    public function getTask(taskID:String):Task {
        return this.tasks[taskID] || this.zeroFrameTasks[taskID];
    }

    // 处理并执行所有到期任务
    public function processTasks():Void {
        // 处理零帧任务
        this.processZeroFrameTasks();

        // 处理调度器到期任务
        var expiredTasks:TaskIDLinkedList = this.scheduler.tick();
        if (expiredTasks != null) {
            var node:TaskIDNode = expiredTasks.getFirst();
            while (node != null) {
                // 缓存下一个节点的引用，防止当前节点被移除后无法继续遍历
                var nextNode:TaskIDNode = node.next;

                var taskID:String = node.taskID;
                trace("Processing taskID: " + taskID);
                if (taskID == null || taskID == "") {
                    trace("TaskManager Error: Encountered a task with invalid ID.");
                    // 从调度器中移除无效的任务节点，防止再次被调度
                    this.scheduler.removeTaskByNode(node);
                    node = nextNode;
                    continue; // 跳过此任务
                }

                var task:Task = this.getTask(taskID);
                if (task) {
                    this.executeTask(task);

                    if (task.isComplete()) {
                        this.removeTask(taskID);
                    } else {
                        // 重新调度任务
                        var newNode:TaskIDNode = this.scheduler.evaluateAndInsertTask(taskID, task.intervalFrames);
                        if (newNode != null) {
                            task.node = newNode;
                            trace("TaskManager: Task " + taskID + " rescheduled with delayFrames " + task.intervalFrames);
                        } else {
                            trace("TaskManager Error: Failed to reschedule Task " + taskID);
                        }
                    }
                } else {
                    trace("TaskManager Warning: Task " + taskID + " not found or already removed.");
                    // 从调度器中移除无效的任务节点
                    this.scheduler.removeTaskByID(taskID);
                }

                // 移动到下一个节点
                node = nextNode;
            }
        }
    }

    // 执行任务并处理错误
    private function executeTask(task:Task):Void {
        if (task == null || task.id == null) {
            trace("TaskManager Warning: Attempted to execute an invalid or null task.");
            return;
        }
        trace("Executing task: " + task.id);
        try {
            task.update();
        } catch (error:Error) {
            trace("TaskManager Error: Task execution failed. ID: " + task.id + ", Error: " + error.message);
            // 确保任务被移除
            if (this.getTask(task.id)) {
                this.removeTask(task.id);
            }
        }
    }

    // 处理零帧任务
    private function processZeroFrameTasks():Void {
        var taskIDs:Array = [];
        for (var taskID:String in this.zeroFrameTasks) {
            taskIDs.push(taskID);
        }
        for (var i:Number = 0; i < taskIDs.length; i++) {
            var taskID:String = taskIDs[i];
            var task:Task = this.zeroFrameTasks[taskID];
            
            if (task == null) {
                trace("TaskManager Warning: Zero-frame Task " + taskID + " not found.");
                continue; // 跳过不存在的任务
            }
            
            this.executeTask(task);

            if (task.isComplete()) {
                delete this.zeroFrameTasks[taskID];
                trace("TaskManager: Zero-frame Task " + taskID + " executed and removed.");
            } else {
                trace("TaskManager: Zero-frame Task " + taskID + " executed and remains.");
            }
        }
    }

    // 延迟任务执行
    public function delayTask(taskID:String, delayTime:Number):Boolean {
        var task:Task = this.getTask(taskID);
        if (task && !task.isInfinite && task.intervalFrames > 0 && task.node != null) {
            var delayFrames:Number = Math.ceil(delayTime * this.frameRatePerMillisecond); // 使用预计算的帧率转换
            task.intervalFrames += delayFrames;
            this.scheduler.rescheduleTaskByNode(task.node, task.intervalFrames);
            trace("TaskManager: Task " + taskID + " delayed by " + delayFrames + " frames.");
            return true;
        }
        trace("TaskManager Error: Delay failed. Task " + taskID + " not found or is a zero-frame task.");
        return false;
    }

    // 内部帮助方法：将任务移至零帧任务队列
    private function moveTaskToZeroFrame(taskID:String, task:Task):Void {
        if (this.tasks[taskID] != undefined) {
            if (task.node != null) {
                this.scheduler.removeTaskByNode(task.node);
                task.node = null; // 清除节点引用
            }
            delete this.tasks[taskID];
            this.zeroFrameTasks[taskID] = task;
            trace("TaskManager: Task " + taskID + " moved to zero-frame tasks.");
        }
    }

    // 内部帮助方法：将任务移至调度器
    private function moveTaskToScheduler(taskID:String, task:Task):Void {
        if (this.zeroFrameTasks[taskID] != undefined) {
            delete this.zeroFrameTasks[taskID];
            var insertedNode:TaskIDNode = this.scheduler.evaluateAndInsertTask(taskID, task.intervalFrames);
            if (insertedNode != null) {
                task.node = insertedNode;
                this.tasks[taskID] = task;
                trace("TaskManager: Task " + taskID + " moved to scheduler.");
            } else {
                trace("TaskManager Error: Failed to reschedule Task " + taskID);
            }
        } else {
            if (task.node != null) {
                this.scheduler.rescheduleTaskByNode(task.node, task.intervalFrames);
                trace("TaskManager: Task " + taskID + " rescheduled in scheduler.");
            } else {
                var insertedNode:TaskIDNode = this.scheduler.evaluateAndInsertTask(taskID, task.intervalFrames);
                if (insertedNode != null) {
                    task.node = insertedNode;
                    this.tasks[taskID] = task;
                    trace("TaskManager: Task " + taskID + " rescheduled with new node.");
                } else {
                    trace("TaskManager Error: Failed to reschedule Task " + taskID);
                }
            }
        }
    }
}

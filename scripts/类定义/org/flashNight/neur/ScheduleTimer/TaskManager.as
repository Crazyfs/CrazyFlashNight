import org.flashNight.neur.ScheduleTimer.*;
import org.flashNight.naki.DataStructures.*;

/**
 * TaskManager 类
 * 
 * 负责管理所有任务的创建、更新、删除和调度。
 * 与 CerberusScheduler 协同工作，确保任务按照指定的时间间隔和重复次数正确执行。
 */
class org.flashNight.neur.ScheduleTimer.TaskManager {
    private var tasks:Object;                // 任务哈希表，存储所有有限重复任务
    private var zeroFrameTasks:Object;       // 零帧任务哈希表，存储需要立即执行的任务（无限或一次性）
    private var taskIDCounter:Number;        // 任务 ID 计数器，确保任务ID唯一性
    private var framesPerMillisecond:Number; // 每毫秒的帧数，用于时间转换
    private var scheduler:CerberusScheduler; // 调度器实例，负责任务调度

    /**
     * 构造函数
     * 
     * @param frameRate 每秒帧数（FPS）
     * @param scheduler 调度器实例
     */
    public function TaskManager(frameRate:Number, scheduler:CerberusScheduler) {
        this.tasks = {};
        this.zeroFrameTasks = {};
        this.taskIDCounter = 0; // 确保任务ID计数器从0开始
        this.framesPerMillisecond = frameRate / 1000;  // 帧率转化为每毫秒的帧数
        this.scheduler = scheduler; // 引入 CerberusScheduler 实例
    }

    /**
     * 创建任务
     * 
     * @param action      任务执行的动作（函数）
     * @param intervalTime 时间间隔（秒）
     * @param repeats     重复次数，0 表示无限循环
     * @param params      动作参数
     * @return            生成的任务ID
     */
    public function createTask(action:Function, intervalTime:Number, repeats:Number, params:Array):String {
        var taskID:String = "task-" + new Date().getTime() + "-" + (++this.taskIDCounter);  // 生成唯一任务ID
        var intervalFrames:Number = Math.ceil(intervalTime * this.framesPerMillisecond * 1000);

        var task:Task = new Task(taskID, action, intervalFrames, repeats, params); // 创建任务实例

        // 区分零帧任务和延迟任务
        if (intervalFrames <= 0) {
            this.zeroFrameTasks[taskID] = task;
            trace("TaskManager: Task " + taskID + " created as zero-frame task. Interval frames: " + intervalFrames + ", repeats: " + repeats);
        } else {
            var insertedNode:TaskIDNode = this.scheduler.evaluateAndInsertTask(taskID, intervalFrames);
            if (insertedNode != null) {
                task.node = insertedNode; // 关联调度器中的任务节点
                this.tasks[taskID] = task;
                trace("TaskManager: Task " + taskID + " created and scheduled. Interval frames: " + intervalFrames + ", repeats: " + repeats);
            } else {
                trace("TaskManager Error: Failed to schedule Task " + taskID);
            }
        }

        return taskID;
    }

    public function createTaskWithID(customTaskID:String, action:Function, intervalTime:Number, repeats:Number, params:Array):String {
        if (this.scheduler.findTaskInTable(customTaskID) != null) {
            trace("TaskManager Error: Custom Task ID " + customTaskID + " already exists.");
            return null;
        }
        var task:Task = new Task(customTaskID, action, Math.ceil(intervalTime * this.framesPerMillisecond * 1000), repeats, params);
        if (task.intervalFrames <= 0) {
            this.zeroFrameTasks[customTaskID] = task;
            trace("TaskManager: Task " + customTaskID + " created as zero-frame task. Interval frames: " + task.intervalFrames + ", repeats: " + repeats);
        } else {
            var insertedNode:TaskIDNode = this.scheduler.evaluateAndInsertTask(customTaskID, task.intervalFrames);
            if (insertedNode != null) {
                task.node = insertedNode;
                this.tasks[customTaskID] = task;
                trace("TaskManager: Task " + customTaskID + " created and scheduled. Interval frames: " + task.intervalFrames + ", repeats: " + repeats);
            } else {
                trace("TaskManager Error: Failed to schedule Task " + customTaskID);
            }
        }
        return customTaskID;
    }



    /**
     * 更新任务
     * 
     * @param taskID       需要更新的任务ID
     * @param action       新的动作函数
     * @param intervalTime 新的时间间隔（秒）
     * @param params       新的动作参数
     */
    public function updateTask(taskID:String, action:Function, intervalTime:Number, params:Array):Void {
        var task:Task = this.getTask(taskID);
        if (task) {
            task.action = action;
            task.intervalFrames = Math.ceil(intervalTime * this.framesPerMillisecond * 1000);
            task.params = params;

            trace("TaskManager: Task " + taskID + " updated. New interval frames: " + task.intervalFrames);

            // 更新调度或零帧任务状态
            if (task.intervalFrames <= 0) {
                this.moveTaskToZeroFrame(taskID, task);
            } else {
                this.moveTaskToScheduler(taskID, task);
            }
        } else {
            trace("TaskManager Error: Update failed. Task " + taskID + " not found.");
        }
    }

    /**
     * 删除任务
     * 
     * @param taskID 要删除的任务ID
     */
    public function removeTask(taskID:String):Void {
        var task:Task = this.getTask(taskID);
        if (task) {
            if (task.node != null) {
                this.scheduler.removeTaskByNode(task.node); // 从调度器中移除任务
                trace("TaskManager: Task " + taskID + " removed from scheduler.");
            }
            task.destroy(); // 清理任务资源
            delete this.tasks[taskID]; // 从任务表中移除
            delete this.zeroFrameTasks[taskID]; // 从零帧任务表中移除（如果存在）
            trace("TaskManager: Task " + taskID + " destroyed and removed from TaskManager.");
        } else {
            trace("TaskManager Error: Remove failed. Task " + taskID + " not found.");
        }
    }

    /**
     * 获取任务
     * 
     * @param taskID 需要获取的任务ID
     * @return       任务实例或 null
     */
    public function getTask(taskID:String):Task {
        return this.tasks[taskID] || this.zeroFrameTasks[taskID];
    }

    /**
     * 处理并执行所有到期任务
     * 
     * 应在每帧调用此方法，处理所有到期任务的执行。
     */
    public function processTasks():Void {
        // 处理零帧任务
        this.processZeroFrameTasks();

        // 调用调度器的 tick 方法获取到期任务
        var expiredTasks:TaskIDLinkedList = this.scheduler.tick();
        if (expiredTasks != null) {
            this.processScheduledTasks(expiredTasks);
        }
    }

    /**
     * 执行任务并处理错误
     * 
     * @param task 需要执行的任务实例
     */
    private function executeTask(task:Task):Void {
        try {
            task.update(); // 执行任务并更新状态
        } catch (error:Error) {
            trace("TaskManager Error: Task execution failed. ID: " + task.id + ", Error: " + error.message);
            // 移除执行失败的任务
            this.removeTask(task.id);
        }
    }


    /**
     * 延迟任务执行
     * 
     * @param taskID    需要延迟的任务ID
     * @param delayTime 延迟时间（秒）
     * @return          延迟是否成功
     */
    public function delayTask(taskID:String, delayTime:Number):Boolean {
        var task:Task = this.getTask(taskID);
        if (task && task.intervalFrames > 0) { // 仅支持延迟调度任务
            var delayFrames:Number = Math.ceil(delayTime * this.framesPerMillisecond * 1000);
            task.waitFrames += delayFrames;
            this.scheduler.rescheduleTaskByNode(task.node, task.waitFrames);
            trace("TaskManager: Task " + taskID + " delayed by " + delayFrames + " frames.");
            return true;
        }
        trace("TaskManager Error: Delay failed. Task " + taskID + " not found or is a zero-frame task.");
        return false;
    }

    /**
     * 处理零帧任务
     * 
     * 零帧任务是需要立即执行的任务，可能是一次性执行或无限循环执行。
     */
    private function processZeroFrameTasks():Void {
        for (var taskID in this.zeroFrameTasks) {
            var task:Task = this.zeroFrameTasks[taskID];
            this.executeTask(task);

            // 确保零帧任务在执行后被移除（如果是一次性任务）
            if (task.isComplete()) {
                delete this.zeroFrameTasks[taskID];
                trace("TaskManager: Zero-frame Task " + taskID + " executed and removed.");
            } else {
                // 如果任务是无限循环（repeats=0），需要重新加入零帧任务队列
                trace("TaskManager: Zero-frame Task " + taskID + " executed and remains for further execution.");
            }
        }
    }

    /**
     * 处理调度到期的任务
     * 
     * @param expiredTasks 到期任务列表
     */
    private function processScheduledTasks(expiredTasks:TaskIDLinkedList):Void {
        var node:TaskIDNode = expiredTasks.getFirst();
        while (node != null) {
            var taskID:String = node.taskID;
            var task:Task = this.tasks[taskID];
            if (task) {
                this.executeTask(task);

                // 检查是否需要重复执行或删除
                if (task.isComplete()) {
                    this.removeTask(taskID);
                    trace("TaskManager: Scheduled Task " + taskID + " executed and removed.");
                } else {
                    // 重新调度任务
                    task.node = this.scheduler.evaluateAndInsertTask(taskID, task.intervalFrames);
                    trace("TaskManager: Scheduled Task " + taskID + " rescheduled.");
                }
            }
            node = node.next;
        }
    }

    /**
     * 将任务移至零帧任务队列
     * 
     * @param taskID 需要移动的任务ID
     * @param task    任务实例
     */
    private function moveTaskToZeroFrame(taskID:String, task:Task):Void {
        if (this.tasks[taskID]) {
            this.scheduler.removeTaskByNode(task.node);
            delete this.tasks[taskID];
            this.zeroFrameTasks[taskID] = task;
            trace("TaskManager: Task " + taskID + " moved to zero-frame tasks.");
        }
    }

    /**
     * 将任务移至调度器
     * 
     * @param taskID 需要移动的任务ID
     * @param task    任务实例
     */
    private function moveTaskToScheduler(taskID:String, task:Task):Void {
        if (this.zeroFrameTasks[taskID]) {
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
            // 重新调度已有的任务节点
            this.scheduler.rescheduleTaskByNode(task.node, task.intervalFrames);
            trace("TaskManager: Task " + taskID + " rescheduled in scheduler.");
        }
    }
}
